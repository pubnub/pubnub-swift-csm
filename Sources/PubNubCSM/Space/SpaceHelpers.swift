//
//  SpaceHelpers.swift
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

// MARK: - Typealias

/// A PubNub Spce that is also Hashable
public typealias HashablePubNubSpace = PubNubSpace & Hashable

/// A String representing the unique identifier for a PubNub Space Object
public typealias SpaceIdResultClosure = (Result<String, Error>) -> Void

// MARK: - Requests

public struct SpaceIdRequest: Equatable {
  public var spaceId: String
  public var include: CustomIncludeField?

  public init(
    spaceId: String,
    include: CustomIncludeField? = .custom
  ) {
    self.spaceId = spaceId
    self.include = include
  }
}

public struct SpaceRequest {
  public var space: PubNubSpace
  public var include: CustomIncludeField? = .custom

  public init(
    space: PubNubSpace,
    include: CustomIncludeField? = .custom
  ) {
    self.space = space
    self.include = include
  }
}

// MARK: - Responses

public protocol SpacesResponse {
  var status: Int { get }
  var spaces: [PubNubSpace] { get }
  var next: String? { get }
  var prev: String? { get }
  var totalCount: Int? { get }

  init<T: PubNubSpace>(from other: SpacesResponse, into: T.Type) throws
}

extension SpacesResponse {
  func transcode<T: SpacesResponse, S: PubNubSpace>(into _: T.Type, underlying _: S.Type) throws -> SpacesResponse {
    if let response = self as? T {
      return response
    }

    return try T(from: self, into: S.self)
  }
}

extension PubNubSpacesResponsePayload: SpacesResponse {
  public var spaces: [PubNubSpace] {
    return data
  }

  public init<T: PubNubSpace>(from other: SpacesResponse, into _: T.Type) {
    self.init(
      status: other.status,
      data: other.spaces,
      totalCount: other.totalCount,
      next: other.next,
      prev: other.prev
    )
  }
}

extension SpacesResponsePayload: SpacesResponse {
  public var spaces: [PubNubSpace] {
    return data
  }

  public init<T: PubNubSpace>(from other: SpacesResponse, into _: T.Type) {
    self.init(
      status: other.status,
      data: other.spaces.compactMap { try? $0.transcode() },
      totalCount: other.totalCount,
      next: other.next,
      prev: other.prev
    )
  }
}
