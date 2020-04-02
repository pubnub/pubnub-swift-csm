//
//  UserAPI.swift
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

// MARK: - PubNubAPI API

public protocol UserAPI {
  func fetchPubNubUsers(
    _ request: ObjectsFetchRequest,
    completion: ((Result<PubNubUsersResponsePayload, Error>) -> Void)?
  )

  func fetchPubNub(
    user request: UserIdRequest,
    completion: ((Result<PubNubUser, Error>) -> Void)?
  )

  func createPubNub(
    user request: UserRequest,
    completion: ((Result<PubNubUser, Error>) -> Void)?
  )

  func updatePubNub(
    user request: UserRequest,
    completion: ((Result<PubNubUser, Error>) -> Void)?
  )

  func delete(
    userId: String,
    completion: ((Result<String, Error>) -> Void)?
  )
}

// MARK: - PubNub Ext

extension PubNub: UserAPI {
  public func fetchPubNubUsers(
    _ request: ObjectsFetchRequest,
    completion: ((Result<PubNubUsersResponsePayload, Error>) -> Void)?
  ) {
    fetchPubNubUsers(
      include: request.include, limit: request.limit,
      start: request.start, end: request.end, count: request.count,
      completion: completion
    )
  }

  public func fetchPubNub(
    user request: UserIdRequest,
    completion: ((Result<PubNubUser, Error>) -> Void)?
  ) {
    fetchPubNub(userID: request.userId, include: request.include, completion: completion)
  }

  public func createPubNub(
    user request: UserRequest,
    completion: ((Result<PubNubUser, Error>) -> Void)?
  ) {
    createPubNub(
      user: request.user,
      include: request.include,
      completion: completion
    )
  }

  public func updatePubNub(
    user request: UserRequest,
    completion: ((Result<PubNubUser, Error>) -> Void)?
  ) {
    updatePubNub(
      user: request.user,
      include: request.include,
      completion: completion
    )
  }

  public func delete(
    userId: String,
    completion: ((Result<String, Error>) -> Void)?
  ) {
    delete(userID: userId) { result in
      completion?(result.map { _ in userId })
    }
  }
}
