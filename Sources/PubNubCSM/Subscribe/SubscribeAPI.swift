//
//  File.swift
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

// MARK: - PubNub API

public struct SubscribeRequest: Codable {
  public var channels: [String]
  public var channelGroups: [String]
  public var timetoken: Timetoken?
  public var withPresence: Bool
  public var presenceState: [String: [String: AnyJSON]]?

  public init(
    channels: [String] = [],
    channelGroups: [String] = [],
    timetoken: Timetoken? = nil,
    withPresence: Bool = false,
    presenceState: [String: [String: JSONCodable]]? = nil
  ) {
    self.channels = channels
    self.channelGroups = channelGroups
    self.timetoken = timetoken
    self.withPresence = withPresence
    self.presenceState = presenceState?.mapValues { $0.mapValues { $0.codableValue } }
  }
}

// MARK: - PubNubAPI API

public protocol SubscribeAPI {
  func set(uuid: String) -> Self

  func subscribe(_ request: SubscribeRequest)
  func reconnect(at: Timetoken?)
  var previousTimetoken: Timetoken? { get }
  func disconnect()
  func unsubscribe(from channels: [String], and groups: [String], presenceOnly: Bool)
  func unsubscribeAll()

  func add(_ listener: SubscriptionListener)
}

// MARK: - PubNub Ext

extension PubNub: SubscribeAPI {
  public func set(uuid: String) -> Self {
    // Copy previous Config
    var config = configuration
    config.uuid = uuid

    // Copy Subscribed channels/groups (??)
    let channels = subscribedChannels
    let groups = subscribedChannelGroups
    let listeners = subscription.listeners

    // Unsubscribe all (Should be done passively if no other instances exist?)
    unsubscribeAll()

    // Create new instance
    let newInstance = PubNub(configuration: config)

    // Copy the listeners
    listeners.forEach { newInstance.add($0) }

    // Subscribe to the channels/groups on new uuid
    newInstance.subscribe(to: channels, and: groups)

    return newInstance
  }

  public func subscribe(_ request: SubscribeRequest) {
    subscribe(
      to: request.channels, and: request.channelGroups,
      at: request.timetoken ?? 0,
      withPresence: request.withPresence,
      setting: request.presenceState ?? [:]
    )
  }
}
