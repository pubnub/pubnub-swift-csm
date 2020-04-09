//
//  MembershipAction.swift
//
//  PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
//  Copyright © 2020 PubNub Inc.
//  https://www.pubnub.com/
//  https://www.pubnub.com/terms
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

import ReSwift

import PubNub

// MARK: - Actions

public enum MembershipActionType: PubNubActionType {
  case startedFetchingMemberships(MembershipFetchRequest)
  case membershipsRetrieved(userId: String, response: MembershipAPIResponse, spaces: [PubNubSpace])
  case errorFetchingMemberships(Error)

  case startedJoiningSpaces(MembershipModifyRequest)
  case spacesJoined(userId: String, response: MembershipAPIResponse, spaces: [PubNubSpace])
  case errorJoiningSpaces(Error)

  case startedUpdatingMemberships(MembershipModifyRequest)
  case membershipsUpdated(userId: String, response: MembershipAPIResponse, spaces: [PubNubSpace])
  case errorUpdatingMemberships(Error)

  case startedLeavingSpaces(MembershipModifyRequest)
  case spacesLeft(userId: String, response: MembershipAPIResponse, leftIds: [String], spaces: [PubNubSpace])
  case errorLeavingSpaces(Error)

  case userAddedToSpaceEvent(membership: PubNubMembership, member: PubNubMember)
  case userMembershipUpdatedOnSpaceEvent(membership: PubNubMembership, member: PubNubMember)
  case userRemovedFromSpaceEvent(userId: String, spaceId: String)

  public func transcode<T: HashablePubNubMembership>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .membershipsRetrieved(userId, response, spaces):
      if let typedResponse = try? MembershipsResponsePayload<T>(protocol: response, into: T.self) {
        return MembershipActionType.membershipsRetrieved(userId: userId, response: typedResponse, spaces: spaces)
      }
    case let .spacesJoined(userId, response, spaces):
      if let typedResponse = try? MembershipsResponsePayload<T>(protocol: response, into: T.self) {
        return MembershipActionType.spacesJoined(userId: userId, response: typedResponse, spaces: spaces)
      }
    case let .membershipsUpdated(userId, response, spaces):
      if let typedResponse = try? MembershipsResponsePayload<T>(protocol: response, into: T.self) {
        return MembershipActionType.membershipsUpdated(userId: userId, response: typedResponse, spaces: spaces)
      }
    case let .spacesLeft(userId, response, leftIds, spaces):
      if let typedResponse = try? MembershipsResponsePayload<T>(protocol: response, into: T.self) {
        return MembershipActionType.spacesLeft(userId: userId, response: typedResponse,
                                               leftIds: leftIds, spaces: spaces)
      }
    case let .userAddedToSpaceEvent(membership, member):
      if let typedMembership = try? membership.transcode(into: T.self) {
        return MembershipActionType.userAddedToSpaceEvent(membership: typedMembership, member: member)
      }
    case let .userMembershipUpdatedOnSpaceEvent(membership, member):
      if let typedMembership = try? membership.transcode(into: T.self) {
        return MembershipActionType.userMembershipUpdatedOnSpaceEvent(membership: typedMembership, member: member)
      }
    default:
      break
    }
    return self
  }

  public func transcode<T: HashablePubNubMember>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .userAddedToSpaceEvent(membership, member):
      if let typedMember = try? member.transcode(into: T.self) {
        return MembershipActionType.userAddedToSpaceEvent(membership: membership, member: typedMember)
      }
    case let .userMembershipUpdatedOnSpaceEvent(membership, member):
      if let typedMember = try? member.transcode(into: T.self) {
        return MembershipActionType.userMembershipUpdatedOnSpaceEvent(membership: membership, member: typedMember)
      }
    default:
      break
    }
    return self
  }

  public func transcode<T: HashablePubNubSpace>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .membershipsRetrieved(userId, response, spaces):
      let typedSpaces = spaces.compactMap { try? $0.transcode(into: T.self) }
      if !typedSpaces.isEmpty {
        return MembershipActionType.membershipsRetrieved(userId: userId, response: response, spaces: typedSpaces)
      }
    case let .spacesJoined(userId, response, spaces):
      let typedSpaces = spaces.compactMap { try? $0.transcode(into: T.self) }
      if !typedSpaces.isEmpty {
        return MembershipActionType.spacesJoined(userId: userId, response: response, spaces: typedSpaces)
      }
    case let .membershipsUpdated(userId, response, spaces):
      let typedSpaces = spaces.compactMap { try? $0.transcode(into: T.self) }
      if !typedSpaces.isEmpty {
        return MembershipActionType.membershipsUpdated(userId: userId, response: response, spaces: typedSpaces)
      }
    case let .spacesLeft(userId, response, leftIds, spaces):
      let typedSpaces = spaces.compactMap { try? $0.transcode(into: T.self) }
      if !typedSpaces.isEmpty {
        return MembershipActionType.spacesLeft(userId: userId, response: response,
                                               leftIds: leftIds, spaces: typedSpaces)
      }
    default:
      break
    }
    return self
  }
}

// MARK: - State

public struct MembershipState<T: HashablePubNubMembership>: StateType, Equatable {
  public var membershipsByUserId: [String: [T]]

  public init(userIdMemberships: [String: [T]] = [:]) {
    membershipsByUserId = userIdMemberships
  }
}

// MARK: - Reducers

public struct MembershipReducer {
  public static func reducer<T: HashablePubNubMembership>(_ action: PubNubActionType, state: inout MembershipState<T>) {
    switch action.transcode(into: T.self) {
    case let action as MembershipActionType:
      typedReducer(action, state: &state)
    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubMembership>(
    _ action: MembershipActionType,
    state: inout MembershipState<T>
  ) {
    switch action {
    case let .membershipsRetrieved(userId, response as MembershipsResponsePayload<T>, _),
         let .spacesJoined(userId, response as MembershipsResponsePayload<T>, _),
         let .membershipsUpdated(userId, response as MembershipsResponsePayload<T>, _):

      if state.membershipsByUserId[userId] != nil {
        state.membershipsByUserId[userId]?.update(contentsOf: response.data)
      } else {
        state.membershipsByUserId[userId] = response.data
      }
    case let .spacesLeft(userId, response as MembershipsResponsePayload<T>, leftIds, _):
      // Remove the the ids of memberships that left
      leftIds.forEach { membershipId in
        state.membershipsByUserId[userId]?.removeAll { $0.id == membershipId }
      }

      // Update any delta from response
      if state.membershipsByUserId[userId] != nil {
        state.membershipsByUserId[userId]?.update(contentsOf: response.data)
      } else {
        state.membershipsByUserId[userId] = response.data
      }

    case let .userAddedToSpaceEvent(membership as T, member),
         let .userMembershipUpdatedOnSpaceEvent(membership as T, member):
      if state.membershipsByUserId[member.userId] != nil {
        state.membershipsByUserId[member.userId]?.update(membership)
      } else {
        state.membershipsByUserId[member.userId] = [membership]
      }
    case let .userRemovedFromSpaceEvent(userId, spaceId):
      state.membershipsByUserId[userId]?.removeAll { $0.spaceId == spaceId }

    default:
      break
    }
  }
}
