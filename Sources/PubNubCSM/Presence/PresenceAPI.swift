//
//  PresenceAPI.swift
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

public protocol PresenceAPI {
  func fetchHereNow(_ request: FetchHereNowRequest, completion: ((Result<HereNowPayload, Error>) -> Void)?)
  func fetchPresenceState(
    _ request: FetchPresenceStateRequest,
    completion: ((Result<[String: [String: AnyJSON]], Error>) -> Void)?
  )
}

// MARK: - PubNub Ext

extension PubNub: PresenceAPI {
  public func fetchHereNow(_ request: FetchHereNowRequest, completion: ((Result<HereNowPayload, Error>) -> Void)?) {
    hereNow(
      on: request.channels,
      and: request.groups,
      includeUUIDs: request.includeUUIDs,
      also: request.includeState,
      completion: completion
    )
  }

  public func fetchPresenceState(
    _ request: FetchPresenceStateRequest,
    completion: ((Result<[String: [String: AnyJSON]], Error>) -> Void)?
  ) {
    getPresenceState(
      for: request.uuid,
      on: request.channels,
      and: request.groups,
      completion: completion ?? { _ in }
    )
  }
}
