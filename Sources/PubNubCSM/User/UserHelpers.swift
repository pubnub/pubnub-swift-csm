//
//  UserHelpers.swift
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

/// A PubNub User that is also Hashable
public typealias HashablePubNubUser = PubNubUser & Hashable

/// A String representing the unique identifier for a PubNub User Object
public typealias UserIdResultClosure = (Result<String, Error>) -> Void

// MARK: - Request

public struct ObjectsFetchRequest: Equatable {
  public var include: CustomIncludeField? = .custom
  public var limit: Int?
  public var start: String?
  public var end: String?
  public var count: Bool? = true

  public init(
    include: CustomIncludeField? = .custom,
    limit: Int? = nil,
    start: String? = nil,
    end: String? = nil,
    count: Bool? = true
  ) {
    self.include = include
    self.limit = limit
    self.start = start
    self.end = end
    self.count = count
  }
}

public struct UserIdRequest: Equatable {
  public var userId: String
  public var include: CustomIncludeField?

  public init(
    userId: String,
    include: CustomIncludeField? = .custom
  ) {
    self.userId = userId
    self.include = include
  }
}

public struct UserRequest {
  public var user: PubNubUser
  public var include: CustomIncludeField? = .custom

  public init(
    user: PubNubUser,
    include: CustomIncludeField? = .custom
  ) {
    self.user = user
    self.include = include
  }
}

// MARK: - Responses

public protocol UsersResponse {
  var status: Int { get }
  var users: [PubNubUser] { get }
  var next: String? { get }
  var prev: String? { get }
  var totalCount: Int? { get }

  init<T: PubNubUser>(from other: UsersResponse, into: T.Type) throws
}

extension UsersResponse {
  func transcode<T: UsersResponse, S: PubNubUser>(into _: T.Type, underlying _: S.Type) throws -> UsersResponse {
    if let response = self as? T {
      return response
    }

    return try T(from: self, into: S.self)
  }
}

extension PubNubUsersResponsePayload: UsersResponse {
  public var users: [PubNubUser] {
    return data
  }

  public init<T: PubNubUser>(from other: UsersResponse, into _: T.Type) {
    self.init(
      status: other.status,
      data: other.users,
      totalCount: other.totalCount,
      next: other.next,
      prev: other.prev
    )
  }
}

extension UsersResponsePayload: UsersResponse {
  public var users: [PubNubUser] {
    return data
  }

  public init<T: PubNubUser>(from other: UsersResponse, into _: T.Type) {
    self.init(
      status: other.status,
      data: other.users.compactMap { try? $0.transcode() },
      totalCount: other.totalCount,
      next: other.next,
      prev: other.prev
    )
  }
}
