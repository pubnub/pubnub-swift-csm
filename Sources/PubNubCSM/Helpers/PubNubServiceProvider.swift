//
//  PubNubServiceProvider.swift
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

import ReSwift

import PubNub

// MARK: - Protocol Wrapper

public typealias ObjectAPI = UserAPI & SpaceAPI & MembershipAPI & MemberAPI
public typealias PubNubAPI = SubscribeAPI & ObjectAPI & MessageAPI & PresenceAPI

// MARK: - Service Provider

public final class PubNubServiceProvider {
  public private(set) var pubnub: PubNubAPI?
  public private(set) var listener: SubscriptionListener?

  public static let shared: PubNubServiceProvider = {
    PubNubServiceProvider()
  }()

  private init() {
    let config = PubNubConfiguration()
    pubnub = PubNub(configuration: config)
  }

  public var context: () -> PubNubAPI? {
    return { [weak self] in
      self?.pubnub
    }
  }

  public func set(service: PubNubAPI?) {
    pubnub = service

    if let listener = listener {
      pubnub?.add(listener)
    }
  }
}

extension PubNubServiceProvider {
  public func set(uuid: String) {
    set(service: pubnub?.set(uuid: uuid))
  }

  public func subscribe(_ channel: String, presence: Bool = false) {
    pubnub?.subscribe(.init(channels: [channel], withPresence: presence))
  }

  public func unsubscribe(_ channel: String, presenceOnly: Bool = false) {
    pubnub?.unsubscribe(from: [channel], and: [], presenceOnly: presenceOnly)
  }

  public func add(listener: SubscriptionListener) {
    self.listener = listener
    pubnub?.add(listener)
  }
}
