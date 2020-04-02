//
//  PresenceHelpers.swift
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

public typealias HashablePrecenseJSON = PrecenseJSON & Hashable
public typealias HashablePrecenseStateJSON = PrecenseStateJSON & Hashable

public typealias PresenceChannelResponseTuple = (
  presenceByChannelId: [String: PrecenseJSON],
  totalOccupancy: Int,
  totalChannels: Int
)

public typealias PresenceStateResponseTuple = (
  userId: String,
  stateByChannelId: [String: PrecenseStateJSON]
)

// MARK: - Requests

public struct FetchHereNowRequest: Equatable {
  public var channels: [String]
  public var groups: [String]
  public var includeUUIDs: Bool
  public var includeState: Bool

  public init(
    channels: [String],
    groups: [String] = [],
    includeUUIDs: Bool = true,
    includeState: Bool = true
  ) {
    self.channels = channels
    self.groups = groups
    self.includeUUIDs = includeUUIDs
    self.includeState = includeState
  }
}

public struct FetchPresenceStateRequest: Equatable {
  public var uuid: String
  public var channels: [String]
  public var groups: [String]

  public init(
    uuid: String,
    channels: [String],
    groups: [String] = []
  ) {
    self.uuid = uuid
    self.channels = channels
    self.groups = groups
  }
}

// MARK: - Responses

public protocol PrecenseJSON {
  var occupancy: Int { get }
  var stateByUserId: [String: PrecenseStateJSON?] { get }
}

extension PrecenseJSON {
  func decodeMemberState<T: PrecenseStateJSON>(_: T.Type) throws -> PrecenseJSON {
    var dict = [String: T?]()

    stateByUserId.forEach { pair in
      if pair.value == nil {
        dict.updateValue(nil, forKey: pair.key)
      } else {
        do {
          if let value = try pair.value?.decodeValue(T.self) {
            dict.updateValue(value, forKey: pair.key)
          }
        } catch {}
      }
    }

    return TypedChannelPresencePayload(occupancy: occupancy, occupants: dict)
  }
}

public protocol PrecenseStateJSON: JSONCodable {
  func decodeValue<T: PrecenseStateJSON>(_ type: T.Type) throws -> T
}

extension PrecenseStateJSON {
  public func decodeValue<T: PrecenseStateJSON>(_: T.Type) throws -> T {
    return try codableValue.decode(T.self)
  }
}

extension Dictionary: PrecenseStateJSON where Key == String, Value: JSONCodable {
  public func decodeValue<T: PrecenseStateJSON>(_: T.Type) throws -> T {
    return try codableValue.decode(T.self)
  }
}

extension HereNowChannelsPayload: PrecenseJSON {
  public var stateByUserId: [String: PrecenseStateJSON?] {
    return occupants
  }
}

public struct TypedChannelPresencePayload<T: PrecenseStateJSON>: PrecenseJSON {
  public var occupancy: Int
  public var occupants: [String: T?]

  public var stateByUserId: [String: PrecenseStateJSON?] {
    return occupants
  }

  init(occupancy: Int = 0, occupants: [String: T?] = [:]) {
    self.occupancy = occupancy
    self.occupants = occupants
  }
}

extension TypedChannelPresencePayload: Equatable where T: Hashable {}
extension TypedChannelPresencePayload: Hashable where T: Hashable {}

extension PresenceEvent {
  var memberState: [String: PrecenseStateJSON] {
    return stateChange.mapValues { $0.mapValues { AnyJSON($0) } }
  }
}
