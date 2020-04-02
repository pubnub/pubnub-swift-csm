//
//  SpaceCommand.swift
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

// MARK: - Commands

public enum SpaceCommand: Action {
  public static func fetchPubNubSpaces(
    _ request: ObjectsFetchRequest,
    completion: @escaping ((Result<PubNubSpacesResponsePayload, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(SpaceActionType.startedFetchingSpaces(request))

      service()?.fetchPubNubSpaces(request) { result in
        switch result {
        case let .success(response):
          dispatch(SpaceActionType.spacesRetrieved(response))
        case let .failure(error):
          dispatch(SpaceActionType.errorFetchingSpaces(error))
        }
        completion(result)
      }
    }
  }

  public static func fetchPubNubSpace(
    _ request: SpaceIdRequest,
    completion: @escaping ((Result<PubNubSpace, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(SpaceActionType.startedFetchingSpace(request))

      service()?.fetchPubNub(space: request) { result in
        switch result {
        case let .success(space):
          dispatch(SpaceActionType.spaceRetrieved(space))
        case let .failure(error):
          dispatch(SpaceActionType.errorFetchingSpace(error))
        }
        completion(result)
      }
    }
  }

  public static func createPubNub(
    _ request: SpaceRequest,
    completion: @escaping ((Result<PubNubSpace, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(SpaceActionType.creatingSpace(request))

      service()?.createPubNub(space: request) { result in
        switch result {
        case let .success(space):
          dispatch(SpaceActionType.spaceCreated(space))
        case let .failure(error):
          dispatch(SpaceActionType.errorCreatingSpace(error))
        }
        completion(result)
      }
    }
  }

  public static func updatePubNub(
    _ request: SpaceRequest,
    completion: @escaping ((Result<PubNubSpace, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(SpaceActionType.updatingSpace(request))

      service()?.updatePubNub(space: request) { result in
        switch result {
        case let .success(space):
          dispatch(SpaceActionType.spaceUpdated(space))
        case let .failure(error):
          dispatch(SpaceActionType.errorUpdatingSpace(error))
        }
        completion(result)
      }
    }
  }

  public static func delete(
    _ spaceId: String,
    completion: @escaping (SpaceIdResultClosure) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in

      dispatch(SpaceActionType.deletingSpace(spaceId: spaceId))

      service()?.delete(spaceId: spaceId) { result in
        switch result {
        case let .success(spaceId):
          dispatch(SpaceActionType.spaceDeleted(spaceId: spaceId))
        case let .failure(error):
          dispatch(SpaceActionType.errorDeletingSpace(error))
        }
        completion(result)
      }
    }
  }
}
