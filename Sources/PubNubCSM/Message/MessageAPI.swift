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

public protocol MessageAPI {
  func sendMessage(
    _ request: SendMessageRequest,
    completion: ((Result<PublishResponsePayload, Error>) -> Void)?
  )
  func fetchMessageHistory(
    _ request: MessageHistoryRequest,
    completion: ((Result<MessageHistoryChannelsPayload, Error>) -> Void)?
  )
}

extension PubNub: MessageAPI {
  public func fetchMessageHistory(
    _ request: MessageHistoryRequest,
    completion: ((Result<MessageHistoryChannelsPayload, Error>) -> Void)?
  ) {
    fetchMessageHistory(
      for: request.channels,
      fetchActions: request.fetchActions,
      max: request.limit,
      start: request.start,
      end: request.end,
      metaInResponse: request.metaInResponse,
      completion: completion
    )
  }

  public func sendMessage(
    _ request: SendMessageRequest,
    completion: ((Result<PublishResponsePayload, Error>) -> Void)?
  ) {
    publish(
      channel: request.channel,
      message: request.content,
      shouldStore: request.storeInHistory,
      storeTTL: request.ttl,
      meta: request.meta,
      shouldCompress: request.shouldCompress,
      completion: completion
    )
  }
}
