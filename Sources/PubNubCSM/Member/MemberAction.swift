//
//  MemberAction.swift
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

public enum MemberActionType: PubNubActionType {
  case startedFetchingMembers(MemberFetchRequest)
  case membersRetrieved(spaceId: String, response: MemberAPIResponse, users: [PubNubUser])
  case errorFetchingMembers(Error)

  case startedAddingMembers(MemberModifyRequest)
  case membersAdded(spaceId: String, response: MemberAPIResponse, users: [PubNubUser])
  case errorAddingSpaces(Error)

  case startedUpdatingMembers(MemberModifyRequest)
  case membersUpdated(spaceId: String, response: MemberAPIResponse, users: [PubNubUser])
  case errorUpdatingMembers(Error)

  case startedRemovingMembers(MemberModifyRequest)
  case membersRemoved(spaceId: String, response: MemberAPIResponse, users: [PubNubUser])
  case errorRemovingMembers(Error)

  public func transcode<T: HashablePubNubMember>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .membersRetrieved(spaceId, response, users):
      if let typedResponse = try? MembersResponsePayload<T>(protocol: response, into: T.self) {
        return MemberActionType.membersRetrieved(spaceId: spaceId, response: typedResponse, users: users)
      }
    case let .membersAdded(spaceId, response, users):
      if let typedResponse = try? MembersResponsePayload<T>(protocol: response, into: T.self) {
        return MemberActionType.membersAdded(spaceId: spaceId, response: typedResponse, users: users)
      }
    case let .membersUpdated(spaceId, response, users):
      if let typedResponse = try? MembersResponsePayload<T>(protocol: response, into: T.self) {
        return MemberActionType.membersUpdated(spaceId: spaceId, response: typedResponse, users: users)
      }
    case let .membersRemoved(spaceId, response, users):
      if let typedResponse = try? MembersResponsePayload<T>(protocol: response, into: T.self) {
        return MemberActionType.membersRemoved(spaceId: spaceId, response: typedResponse, users: users)
      }
    default:
      break
    }
    return self
  }

  public func transcode<T: HashablePubNubUser>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .membersRetrieved(spaceId, response, users):
      let typedUsers = users.compactMap { try? $0.transcode(into: T.self) }
      if !typedUsers.isEmpty {
        return MemberActionType.membersRetrieved(spaceId: spaceId, response: response, users: typedUsers)
      }
    case let .membersAdded(spaceId, response, users):
      let typedUsers = users.compactMap { try? $0.transcode(into: T.self) }
      if !typedUsers.isEmpty {
        return MemberActionType.membersAdded(spaceId: spaceId, response: response, users: typedUsers)
      }
    case let .membersUpdated(spaceId, response, users):
      let typedUsers = users.compactMap { try? $0.transcode(into: T.self) }
      if !typedUsers.isEmpty {
        return MemberActionType.membersUpdated(spaceId: spaceId, response: response, users: typedUsers)
      }
    case let .membersRemoved(spaceId, response, users):
      let typedUsers = users.compactMap { try? $0.transcode(into: T.self) }
      if !typedUsers.isEmpty {
        return MemberActionType.membersRemoved(spaceId: spaceId, response: response, users: typedUsers)
      }
    default:
      break
    }
    return self
  }
}

// MARK: - State

public struct MemberState<T: HashablePubNubMember>: StateType, Equatable {
  public var membersBySpaceId: [String: [T]]

  public init(membersBySpaceId: [String: [T]] = [:]) {
    self.membersBySpaceId = membersBySpaceId
  }
}

// MARK: - Reducers

public struct MemberReducer {
  public static func reducer<T: HashablePubNubMember>(_ action: PubNubActionType, state: inout MemberState<T>) {
    switch action.transcode(into: T.self) {
    case let action as MemberActionType:
      typedReducer(action, state: &state)
    case let action as MembershipActionType:
      typedReducer(action, state: &state)
    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubMember>(_ action: MemberActionType, state: inout MemberState<T>) {
    switch action {
    case let .membersRetrieved(spaceId, response as MembersResponsePayload<T>, _),
         let .membersAdded(spaceId, response as MembersResponsePayload<T>, _),
         let .membersUpdated(spaceId, response as MembersResponsePayload<T>, _),
         let .membersRemoved(spaceId, response as MembersResponsePayload<T>, _):
      if state.membersBySpaceId[spaceId] != nil {
        state.membersBySpaceId[spaceId]?.update(contentsOf: response.data)
      } else {
        state.membersBySpaceId[spaceId] = response.data
      }

    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubMember>(_ action: MembershipActionType, state: inout MemberState<T>) {
    switch action {
    case let .userAddedToSpaceEvent(membership, member as T),
         let .userMembershipUpdatedOnSpaceEvent(membership, member as T):
      if state.membersBySpaceId[membership.spaceId] != nil {
        state.membersBySpaceId[membership.spaceId]?.update(member)
      } else {
        state.membersBySpaceId[membership.spaceId] = [member]
      }

    case let .userRemovedFromSpaceEvent(userId, spaceId):
      state.membersBySpaceId[spaceId]?.removeAll { $0.userId == userId }

    default:
      break
    }
  }
}
