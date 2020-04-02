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

// MARK: - Typealias

public typealias HashablePubNubMessageEnvelop = MessageEnvelop & Hashable

public typealias MessageTuple = (channelId: String, message: JSONCodable, sentAt: Timetoken)

/// A String representing the unique identifier for a PubNub User Object
public typealias MessageByChannelIdClosure = (Result<[String: [JSONMessage]], Error>) -> Void

// MARK: - Requests

public struct SendMessageRequest: Equatable {
  public let content: JSONCodable
  public let channel: String
  public let storeInHistory: Bool?
  public let shouldCompress: Bool
  public let meta: JSONCodable?
  public let ttl: Int?

  public init(
    content: JSONCodable,
    channel: String,
    storeInHistory: Bool? = nil,
    shouldCompress: Bool = false,
    meta: JSONCodable? = nil,
    ttl: Int? = nil
  ) {
    self.content = content
    self.channel = channel
    self.storeInHistory = storeInHistory
    self.shouldCompress = shouldCompress
    self.meta = meta
    self.ttl = ttl
  }

  public static func == (lhs: SendMessageRequest, rhs: SendMessageRequest) -> Bool {
    return lhs.channel == rhs.channel &&
      lhs.storeInHistory == rhs.storeInHistory &&
      lhs.shouldCompress == rhs.shouldCompress &&
      lhs.ttl == rhs.ttl &&
      lhs.content.codableValue == rhs.content.codableValue &&
      lhs.meta?.codableValue == rhs.meta?.codableValue
  }
}

public struct MessageHistoryRequest: Equatable {
  public let channels: [String]
  public let fetchActions: Bool
  public let limit: Int?
  public let start: Timetoken?
  public let end: Timetoken?
  public let metaInResponse: Bool

  public init(
    channels: [String],
    fetchActions: Bool = false,
    limit: Int? = nil,
    start: Timetoken? = nil,
    end: Timetoken? = nil,
    metaInResponse: Bool = false
  ) {
    self.channels = channels
    self.fetchActions = fetchActions
    self.limit = limit
    self.start = start
    self.end = end
    self.metaInResponse = metaInResponse
  }
}

// MARK: - Responses

public protocol JSONMessage: Codable {
  var timetoken: Timetoken { get }
  /// A message that can be represented as Codable JSON
  var codableMessage: JSONCodable { get }
}

extension JSONMessage {
  public func decodeMessage<T: Codable>(_: T.Type) throws -> T {
    return try codableMessage.codableValue.decode(T.self)
  }
}

extension MessageHistoryMessagesPayload: MessageEnvelop {
  public var channel: String {
    return ""
  }

  public init(channel _: String, message: AnyJSON, at timetoken: Timetoken) {
    self.init(
      message: message,
      timetoken: timetoken
    )
  }
}

// MARK: - General Protocol

public protocol MessageEnvelop: JSONMessage {
  associatedtype Content: JSONCodable, Equatable

  var id: String { get }
  var channel: String { get }
  var timetoken: Timetoken { get }

  var message: Content { get }

//  init(channel: String, message: JSONCodable, at timetoken: Timetoken) throws
  init(channel: String, message: Content, at timetoken: Timetoken)
}

extension MessageEnvelop {
  public var id: String {
    return timetoken.description
  }

  public var codableMessage: JSONCodable {
    return message
  }
}
