//
//  SpaceAction.swift
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

import PubNub

import ReSwift

// MARK: - Actions

public enum SpaceActionType: PubNubActionType {
  case startedFetchingSpaces(ObjectsFetchRequest)
  case spacesRetrieved(SpacesResponse)
  case errorFetchingSpaces(Error)

  case startedFetchingSpace(SpaceIdRequest)
  case spaceRetrieved(PubNubSpace)
  case errorFetchingSpace(Error)

  case creatingSpace(SpaceRequest)
  case spaceCreated(PubNubSpace)
  case errorCreatingSpace(Error)

  case updatingSpace(SpaceRequest)
  case spaceUpdated(PubNubSpace)
  case errorUpdatingSpace(Error)

  case deletingSpace(spaceId: String)
  case spaceDeleted(spaceId: String)
  case errorDeletingSpace(Error)

  case spaceUpdatedEvent(SpaceEvent)
  case spaceDeletedEvent(spaceId: String)

  public func transcode<T: HashablePubNubSpace>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .spacesRetrieved(response):
      if let typedResponse = try? response.transcode(into: SpacesResponsePayload<T>.self, underlying: T.self) {
        return SpaceActionType.spacesRetrieved(typedResponse)
      }
    case let .spaceRetrieved(space):
      if let typedSpace = try? space.transcode(into: T.self) {
        return SpaceActionType.spaceRetrieved(typedSpace)
      }
    case let .spaceCreated(space):
      if let typedSpace = try? space.transcode(into: T.self) {
        return SpaceActionType.spaceCreated(typedSpace)
      }
    case let .spaceUpdated(space):
      if let typedSpace = try? space.transcode(into: T.self) {
        return SpaceActionType.spaceUpdated(typedSpace)
      }
    default:
      break
    }
    return self
  }
}

// MARK: - State

public struct SpaceState<T: HashablePubNubSpace>: StateType, Equatable {
  public var spaces: [String: T]

  public init(spaces: [String: T] = [:]) {
    self.spaces = spaces
  }
}

// MARK: - Reducers

public struct SpaceReducer {
  public static func reducer<T: HashablePubNubSpace>(_ action: PubNubActionType, state: inout SpaceState<T>) {
    switch action.transcode(into: T.self) {
    case let action as SpaceActionType:
      typedReducer(action, state: &state)
    case let action as MembershipActionType:
      typedReducer(action, state: &state)
    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubSpace>(_ action: SpaceActionType, state: inout SpaceState<T>) {
    switch action {
    case let .spacesRetrieved(response as SpacesResponsePayload<T>):
      response.data.forEach { state.spaces[$0.id] = $0 }

    case let .spaceRetrieved(space as T),
         let .spaceCreated(space as T),
         let .spaceUpdated(space as T):
      state.spaces.updatePubNub(space, forKey: space.id)

    case let .spaceUpdatedEvent(patch):
      if let space = try? patch.update(state.spaces[patch.id]) {
        state.spaces.updatePubNub(space, forKey: space.id)
      }

    case let .spaceDeleted(spaceId),
         let .spaceDeletedEvent(spaceId):
      state.spaces.removeValue(forKey: spaceId)

    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubSpace>(_ action: MembershipActionType, state: inout SpaceState<T>) {
    switch action {
    // Avoiding `Downcast pattern value of type '[T]' cannot be used` compiler warning:
    // https://bugs.swift.org/browse/SR-5671
    // https://bugs.swift.org/browse/SR-6192
    case let .membershipsRetrieved(_, _, (spaces as [T]) as Any),
         let .spacesJoined(_, _, (spaces as [T]) as Any),
         let .membershipsUpdated(_, _, (spaces as [T]) as Any),
         let .spacesLeft(_, _, _, (spaces as [T]) as Any):
      spaces.forEach { state.spaces.updatePubNub($0, forKey: $0.id) }
    default:
      break
    }
  }
}
