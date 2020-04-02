//
//  UserAction.swift
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

public enum UserActionType: PubNubActionType {
  case startedFetchingUsers(ObjectsFetchRequest)
  case usersRetrieved(UsersResponse)
  case errorFetchingUsers(Error)

  case startedFetchingUser(UserIdRequest)
  case userRetrieved(PubNubUser)
  case errorFetchingUser(Error)

  case creatingUser(UserRequest)
  case userCreated(PubNubUser)
  case errorCreatingUser(Error)

  case updatingUser(UserRequest)
  case userUpdated(PubNubUser)
  case errorUpdatingUser(Error)

  case deletingUser(userId: String)
  case userDeleted(userId: String)
  case errorDeletingUser(Error)

  case userUpdatedEvent(UserEvent)
  case userDeletedEvent(userId: String)

  public func transcode<T: HashablePubNubUser>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .usersRetrieved(response):
      if let typedResponse = try? response.transcode(into: UsersResponsePayload<T>.self, underlying: T.self) {
        return UserActionType.usersRetrieved(typedResponse)
      }
    case let .userRetrieved(user):
      if let typedUser = try? user.transcode(into: T.self) {
        return UserActionType.userRetrieved(typedUser)
      }
    case let .userCreated(user):
      if let typedUser = try? user.transcode(into: T.self) {
        return UserActionType.userCreated(typedUser)
      }
    case let .userUpdated(user):
      if let typedUser = try? user.transcode(into: T.self) {
        return UserActionType.userUpdated(typedUser)
      }
    default:
      break
    }
    return self
  }
}

// MARK: - State

public struct UserState<T: HashablePubNubUser>: StateType, Equatable {
  public var users: [String: T]

  public init(users: [String: T] = [:]) {
    self.users = users
  }
}

// MARK: - Reducers

public struct UserReducer {
  public static func reducer<T: HashablePubNubUser>(_ action: PubNubActionType, state: inout UserState<T>) {
    switch action.transcode(into: T.self) {
    case let action as UserActionType:
      typedReducer(action, state: &state)
    case let action as MemberActionType:
      typedReducer(action, state: &state)
    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubUser>(_ action: UserActionType, state: inout UserState<T>) {
    switch action {
    case let .usersRetrieved(response as UsersResponsePayload<T>):
      response.data.forEach { state.users[$0.id] = $0 }

    case let .userRetrieved(user as T),
         let .userCreated(user as T),
         let .userUpdated(user as T):
      state.users.updatePubNub(user, forKey: user.id)

    case let .userUpdatedEvent(patch):
      if let user = try? patch.update(state.users[patch.id]) {
        state.users.updatePubNub(user, forKey: patch.id)
      }

    case let .userDeleted(userId),
         let .userDeletedEvent(userId):
      state.users.removeValue(forKey: userId)

    default:
      break
    }
  }

  static func typedReducer<T: HashablePubNubUser>(_ action: MemberActionType, state: inout UserState<T>) {
    switch action {
    case let .membersRetrieved(_, _, (users as [T]) as Any),
         let .membersAdded(_, _, (users as [T]) as Any),
         let .membersUpdated(_, _, (users as [T]) as Any),
         let .membersRemoved(_, _, (users as [T]) as Any):
      users.forEach { state.users.updatePubNub($0, forKey: $0.id) }
    default:
      break
    }
  }
}
