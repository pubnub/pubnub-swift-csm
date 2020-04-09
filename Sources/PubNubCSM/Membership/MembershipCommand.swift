//
//  MembershipCommand.swift
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

public enum MembershipCommand: Action {
  public static func fetchPubNubMemberships(
    _ request: MembershipFetchRequest,
    completion: @escaping ((Result<MembershipResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MembershipActionType.startedFetchingMemberships(request))

      service()?.fetchPubNubMemberships(request) { result in
        switch result {
        case let .success(response):
          dispatch(MembershipActionType.membershipsRetrieved(
            userId: request.userId,
            response: response,
            spaces: response.data.compactMap { $0.space }
          ))
          completion(.success((
            userId: request.userId,
            response: response,
            spaces: response.data.compactMap { $0.space }
          )))
        case let .failure(error):
          dispatch(MembershipActionType.errorFetchingMemberships(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func join(
    _ request: MembershipModifyRequest,
    completion: @escaping ((Result<MembershipResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MembershipActionType.startedJoiningSpaces(request))

      service()?.joinPubNub(memberships: request) { result in
        switch result {
        case let .success(response):
          dispatch(MembershipActionType.spacesJoined(
            userId: request.userId,
            response: response,
            spaces: response.data.compactMap { $0.space }
          ))
          completion(.success((
            userId: request.userId,
            response: response,
            spaces: response.data.compactMap { $0.space }
          )))
        case let .failure(error):
          dispatch(MembershipActionType.errorJoiningSpaces(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func update(
    _ request: MembershipModifyRequest,
    completion: @escaping ((Result<MembershipResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MembershipActionType.startedUpdatingMemberships(request))

      service()?.updatePubNub(memberships: request) { result in
        switch result {
        case let .success(response):
          dispatch(MembershipActionType.membershipsUpdated(
            userId: request.userId,
            response: response,
            spaces: response.data.compactMap { $0.space }
          ))
          completion(.success((
            userId: request.userId,
            response: response,
            spaces: response.data.compactMap { $0.space }
          )))
        case let .failure(error):
          dispatch(MembershipActionType.errorUpdatingMemberships(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func leave(
    _ request: MembershipModifyRequest,
    completion: @escaping ((Result<MembershipsLeftResponseTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MembershipActionType.startedLeavingSpaces(request))

      service()?.leavePubNub(memberships: request) { result in
        switch result {
        case let .success(response):
          dispatch(MembershipActionType.spacesLeft(
            userId: request.userId,
            response: response,
            leftIds: request.modifiedBy.map { $0.id },
            spaces: response.data.compactMap { $0.space }
          ))
          completion(.success((
            userId: request.userId,
            response: response,
            leftIds: request.modifiedBy.map { $0.id },
            spaces: response.data.compactMap { $0.space }
          )))
        case let .failure(error):
          dispatch(MembershipActionType.errorLeavingSpaces(error))
          completion(.failure(error))
        }
      }
    }
  }
}
