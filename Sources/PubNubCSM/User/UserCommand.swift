//
//  UserCommand.swift
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

public enum UserCommand: Action {
  public static func fetchPubNubUsers(
    _ request: ObjectsFetchRequest,
    completion: @escaping ((Result<PubNubUsersResponsePayload, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(UserActionType.startedFetchingUsers(request))

      service()?.fetchPubNubUsers(request) { result in
        switch result {
        case let .success(response):
          dispatch(UserActionType.usersRetrieved(response))
        case let .failure(error):
          dispatch(UserActionType.errorFetchingUsers(error))
        }
        completion(result)
      }
    }
  }

  public static func fetchPubNubUser(
    _ request: UserIdRequest,
    completion: @escaping ((Result<PubNubUser, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(UserActionType.startedFetchingUser(request))

      service()?.fetchPubNub(user: request) { result in
        switch result {
        case let .success(user):
          dispatch(UserActionType.userRetrieved(user))
        case let .failure(error):
          dispatch(UserActionType.errorFetchingUser(error))
        }
        completion(result)
      }
    }
  }

  public static func createPubNub(
    _ request: UserRequest,
    completion: @escaping ((Result<PubNubUser, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(UserActionType.creatingUser(request))

      service()?.createPubNub(user: request) { result in
        switch result {
        case let .success(user):
          dispatch(UserActionType.userCreated(user))
        case let .failure(error):
          dispatch(UserActionType.errorCreatingUser(error))
        }
        completion(result)
      }
    }
  }

  public static func updatePubNub(
    _ request: UserRequest,
    completion: @escaping ((Result<PubNubUser, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(UserActionType.updatingUser(request))

      service()?.updatePubNub(user: request) { result in
        switch result {
        case let .success(user):
          dispatch(UserActionType.userUpdated(user))
        case let .failure(error):
          dispatch(UserActionType.errorUpdatingUser(error))
        }
        completion(result)
      }
    }
  }

  public static func delete(
    _ userId: String,
    completion: @escaping (UserIdResultClosure) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(UserActionType.deletingUser(userId: userId))

      service()?.delete(userId: userId) { result in
        switch result {
        case let .success(userId):
          dispatch(UserActionType.userDeleted(userId: userId))
        case let .failure(error):
          dispatch(UserActionType.errorDeletingUser(error))
        }
        completion(result)
      }
    }
  }
}
