//
//  SpaceAPI.swift
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

public protocol SpaceAPI {
  func fetchPubNubSpaces(
    _ request: ObjectsFetchRequest,
    completion: ((Result<PubNubSpacesResponsePayload, Error>) -> Void)?
  )

  func fetchPubNub(
    space request: SpaceIdRequest,
    completion: ((Result<PubNubSpace, Error>) -> Void)?
  )

  func createPubNub(
    space request: SpaceRequest,
    completion: ((Result<PubNubSpace, Error>) -> Void)?
  )

  func updatePubNub(
    space request: SpaceRequest,
    completion: ((Result<PubNubSpace, Error>) -> Void)?
  )

  func delete(
    spaceId: String,
    completion: ((Result<String, Error>) -> Void)?
  )
}

// MARK: - PubNub Ext

extension PubNub: SpaceAPI {
  public func fetchPubNubSpaces(
    _ request: ObjectsFetchRequest,
    completion: ((Result<PubNubSpacesResponsePayload, Error>) -> Void)?
  ) {
    fetchPubNubSpaces(
      include: request.include, limit: request.limit,
      start: request.start, end: request.end, count: request.count,
      completion: completion
    )
  }

  public func fetchPubNub(
    space request: SpaceIdRequest,
    completion: ((Result<PubNubSpace, Error>) -> Void)?
  ) {
    fetchPubNub(spaceID: request.spaceId, include: request.include, completion: completion)
  }

  public func createPubNub(
    space request: SpaceRequest,
    completion: ((Result<PubNubSpace, Error>) -> Void)?
  ) {
    createPubNub(
      space: request.space,
      include: request.include,
      completion: completion
    )
  }

  public func updatePubNub(
    space request: SpaceRequest,
    completion: ((Result<PubNubSpace, Error>) -> Void)?
  ) {
    updatePubNub(
      space: request.space,
      include: request.include,
      completion: completion
    )
  }

  public func delete(
    spaceId: String,
    completion: ((Result<String, Error>) -> Void)?
  ) {
    delete(spaceID: spaceId) { result in
      completion?(result.map { _ in spaceId })
    }
  }
}
