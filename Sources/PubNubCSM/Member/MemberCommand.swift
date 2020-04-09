//
//  MemberCommand.swift
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

public enum MemberCommand: Action {
  public static func fetchMembers(
    _ request: MemberFetchRequest,
    completion: @escaping ((Result<MemberResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MemberActionType.startedFetchingMembers(request))

      service()?.fetchPubNubMembers(request) { result in
        switch result {
        case let .success(response):
          dispatch(MemberActionType.membersRetrieved(
            spaceId: request.spaceId,
            response: response,
            users: response.data.compactMap { $0.user }
          ))
          completion(.success((
            spaceId: request.spaceId,
            response: response,
            users: response.data.compactMap { $0.user }
          )))
        case let .failure(error):
          dispatch(MemberActionType.errorFetchingMembers(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func add(
    _ request: MemberModifyRequest,
    completion: @escaping ((Result<MemberResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MemberActionType.startedAddingMembers(request))

      service()?.addPubNub(members: request) { result in
        switch result {
        case let .success(response):
          dispatch(MemberActionType.membersAdded(
            spaceId: request.spaceId,
            response: response,
            users: response.data.compactMap { $0.user }
          ))
          completion(.success((
            spaceId: request.spaceId,
            response: response,
            users: response.data.compactMap { $0.user }
          )))
        case let .failure(error):
          dispatch(MemberActionType.errorAddingSpaces(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func update(
    _ request: MemberModifyRequest,
    completion: @escaping ((Result<MemberResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MemberActionType.startedUpdatingMembers(request))

      service()?.updatePubNub(members: request) { result in
        switch result {
        case let .success(response):
          dispatch(MemberActionType.membersUpdated(
            spaceId: request.spaceId,
            response: response,
            users: response.data.compactMap { $0.user }
          ))
          completion(.success((
            spaceId: request.spaceId,
            response: response,
            users: response.data.compactMap { $0.user }
          )))
        case let .failure(error):
          dispatch(MemberActionType.errorUpdatingMembers(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func remove(
    _ request: MemberModifyRequest,
    completion: @escaping ((Result<MemberRemovedResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MemberActionType.startedRemovingMembers(request))

      service()?.removePubNub(members: request) { result in
        switch result {
        case let .success(response):
          dispatch(MemberActionType.membersRemoved(
            spaceId: request.spaceId,
            response: response,
            removedIds: request.modifiedBy.map { $0.id },
            users: response.data.compactMap { $0.user }
          ))
          completion(.success((
            spaceId: request.spaceId,
            response: response,
            removedIds: request.modifiedBy.map { $0.id },
            users: response.data.compactMap { $0.user }
          )))
        case let .failure(error):
          dispatch(MemberActionType.errorRemovingMembers(error))
          completion(.failure(error))
        }
      }
    }
  }
}
