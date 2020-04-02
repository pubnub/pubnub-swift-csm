//
//  MembershipAPI.swift
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

public protocol MembershipAPI {
  func fetchPubNubMemberships(
    _ request: MembershipFetchRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  )

  func joinPubNub(
    memberships request: MembershipModifyRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  )

  func updatePubNub(
    memberships request: MembershipModifyRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  )

  func leavePubNub(
    memberships request: MembershipModifyRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  )
}

// MARK: - PubNub Ext

extension PubNub: MembershipAPI {
  public func fetchPubNubMemberships(
    _ request: MembershipFetchRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  ) {
    fetchPubNubMemberships(
      userID: request.userId, include: request.include,
      limit: request.limit, start: request.start, end: request.end, count: request.count,
      completion: completion
    )
  }

  public func joinPubNub(
    memberships request: MembershipModifyRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  ) {
    modifyPubNubMemberships(
      userID: request.userId,
      joining: request.modifiedBy,
      include: request.include, limit: request.limit,
      start: request.start, end: request.end,
      count: request.count, completion: completion
    )
  }

  public func updatePubNub(
    memberships request: MembershipModifyRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  ) {
    modifyPubNubMemberships(
      userID: request.userId,
      updating: request.modifiedBy,
      include: request.include, limit: request.limit,
      start: request.start, end: request.end,
      count: request.count, completion: completion
    )
  }

  public func leavePubNub(
    memberships request: MembershipModifyRequest,
    completion: ((Result<PubNubMembershipsResponsePayload, Error>) -> Void)?
  ) {
    modifyPubNubMemberships(
      userID: request.userId,
      leaving: request.modifiedBy.map { $0.spaceId },
      include: request.include, limit: request.limit,
      start: request.start, end: request.end,
      count: request.count, completion: completion
    )
  }
}
