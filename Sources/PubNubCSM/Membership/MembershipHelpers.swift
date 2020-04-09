//
//  MembershipHelpers.swift
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

/// A PubNub Membership that is also Hashable
public typealias HashablePubNubMembership = PubNubMembership & Hashable

public typealias MembershipResponseTuple = (
  userId: String,
  response: PubNubMembershipsResponsePayload,
  spaces: [PubNubSpace]
)

public typealias MembershipsLeftResponseTuple = (
  userId: String,
  response: PubNubMembershipsResponsePayload,
  leftIds: [String],
  spaces: [PubNubSpace]
)

// MARK: - Requests

public struct MembershipFetchRequest: Equatable {
  public var userId: String
  public var include: [CustomIncludeField]?
  public var limit: Int?
  public var start: String?
  public var end: String?
  public var count: Bool?

  public init(
    userId: String,
    include: [CustomIncludeField]? = [.custom, .space, .customSpace],
    limit: Int? = nil,
    start: String? = nil,
    end: String? = nil,
    count: Bool? = nil
  ) {
    self.userId = userId
    self.include = include
    self.limit = limit
    self.start = start
    self.end = end
    self.count = count
  }
}

public struct MembershipModifyRequest {
  public var userId: String
  public var modifiedBy: [PubNubMembership]
  public var include: [CustomIncludeField]? = [.custom, .space, .customSpace]
  public var limit: Int?
  public var start: String?
  public var end: String?
  public var count: Bool?

  public init(
    userId: String,
    modifiedBy: [PubNubMembership],
    include: [CustomIncludeField]? = [.custom, .space, .customSpace],
    limit: Int? = nil,
    start: String? = nil,
    end: String? = nil,
    count: Bool? = nil
  ) {
    self.userId = userId
    self.modifiedBy = modifiedBy
    self.include = include
    self.limit = limit
    self.start = start
    self.end = end
    self.count = count
  }
}

// MARK: - Responses

public protocol MembershipAPIResponse {
  var status: Int { get }
  var memberships: [PubNubMembership] { get }
  var totalCount: Int? { get }
  var next: String? { get }
  var prev: String? { get }

  init<T: PubNubMembership>(
    protocol response: MembershipAPIResponse,
    into custom: T.Type
  ) throws
}

extension PubNubMembershipsResponsePayload: MembershipAPIResponse {
  public var memberships: [PubNubMembership] {
    return data
  }

  public init<T: PubNubMembership>(
    protocol response: MembershipAPIResponse,
    into _: T.Type
  ) throws {
    self.init(
      status: response.status,
      data: response.memberships,
      totalCount: response.totalCount,
      next: response.next,
      prev: response.prev
    )
  }
}

extension MembershipsResponsePayload: MembershipAPIResponse {
  public var memberships: [PubNubMembership] {
    return data
  }

  public init<T: PubNubMembership>(
    protocol response: MembershipAPIResponse,
    into _: T.Type
  ) throws {
    try self.init(
      status: response.status,
      data: try response.memberships.map { try $0.transcode() },
      totalCount: response.totalCount,
      next: response.next,
      prev: response.prev
    )
  }
}
