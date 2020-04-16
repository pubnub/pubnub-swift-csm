//
//  MessageAction.swift
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

import ReSwift

// MARK: - Actions

public enum MessageActionType: PubNubActionType {
  case sendingMessage(SendMessageRequest)
  case messageSent(channelId: String, message: JSONCodable, sentAt: Timetoken)
  case errorSendingMessage(Error)

  case fetchingMessageHistory(MessageHistoryRequest)
  case messageHistoryRetrieved(messageByChannelId: [String: [JSONMessage]])
  case errorFetchingMessageHistory(Error)

  case receivedMessageEvent(channelId: String, message: JSONCodable, sentAt: Timetoken)

  public func transcode<T: HashablePubNubMessageEnvelop>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .messageSent(channelId, payload, timetoken):
      if let value = try? payload.codableValue.decode(T.Content.self) {
        return MessageActionType.messageSent(channelId: channelId, message: value, sentAt: timetoken)
      }

    case let .receivedMessageEvent(channelId, payload, timetoken):
      if let value = try? payload.codableValue.decode(T.Content.self) {
        return MessageActionType.receivedMessageEvent(channelId: channelId, message: value, sentAt: timetoken)
      }

    case let .messageHistoryRetrieved(dictionary):
      let messages = dictionary
        .reduce(
          into: [:]
        ) { (result: inout [String: [T]], tuple: (key: String, value: [JSONMessage])) in
          result[tuple.key] = tuple.value.compactMap {
            do {
              return T(
                channel: tuple.key,
                message: try $0.decodeMessage(T.Content.self),
                at: $0.timetoken
              )
            } catch {
              return nil
            }
          }
        }

      if !messages.allSatisfy({ $1.isEmpty }) {
        return MessageActionType.messageHistoryRetrieved(messageByChannelId: messages)
      }

    default:
      break
    }

    return self
  }
}

// MARK: - State

public struct MessageState<T: HashablePubNubMessageEnvelop>: StateType, Equatable {
  public var messagesByChannel: [String: [T]]

  public init(messages: [String: [T]] = [:]) {
    messagesByChannel = messages
  }
}

// MARK: - Reducers

public struct MessageReducer {
  public static func reducer<T: HashablePubNubMessageEnvelop>(
    _ action: PubNubActionType,
    state: inout MessageState<T>
  ) {
    switch action.transcode(into: T.self) {
    case let action as MessageActionType:
      typedReducer(action, state: &state)
    default:
      break
    }
  }

  typealias TypedHistoryResponse<T: HashablePubNubMessageEnvelop> = (T.Content, Timetoken, [MessageActionPayload])

  static func typedReducer<T: HashablePubNubMessageEnvelop>(_ action: MessageActionType, state: inout MessageState<T>) {
    switch action {
    case let .messageSent(channelId, payload as T.Content, timetoken),
         let .receivedMessageEvent(channelId, payload as T.Content, timetoken):
      state.messagesByChannel
        .merge(
          [channelId: [T(channel: channelId, message: payload, at: timetoken)]]
        ) { $0.deduplicate(by: \.timetoken, contentsOf: $1) }

    case let .messageHistoryRetrieved((response as [String: [T]]) as Any):
      state.messagesByChannel.merge(response) { $0.deduplicate(by: \.timetoken, contentsOf: $1) }

    default:
      break
    }
  }
}
