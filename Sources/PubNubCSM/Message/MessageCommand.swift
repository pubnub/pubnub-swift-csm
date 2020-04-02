//
//  MessageCommand.swift
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

// MARK: - Commands

public enum MessageCommand: Action {
  public static func sendMessage(
    _ request: SendMessageRequest,
    completion: @escaping ((Result<MessageTuple, Error>) -> Void) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MessageActionType.sendingMessage(request))

      service()?.sendMessage(request) { result in
        switch result {
        case let .success(response):
          dispatch(MessageActionType.messageSent(
            channelId: request.channel,
            message: request.content,
            sentAt: response.timetoken
          ))
          completion(.success((
            channelId: request.channel,
            message: request.content,
            sentAt: response.timetoken
          )))
        case let .failure(error):
          dispatch(MessageActionType.errorSendingMessage(error))
          completion(.failure(error))
        }
      }
    }
  }

  public static func fetchMessageHistory(
    _ request: MessageHistoryRequest,
    completion: @escaping (MessageByChannelIdClosure) = { _ in }
  ) -> ThunkAction {
    return ThunkAction { dispatch, _, service in
      dispatch(MessageActionType.fetchingMessageHistory(request))

      service()?.fetchMessageHistory(request) { result in
        switch result {
        case let .success(response):
          let payloadResponse = response.mapValues { $0.messages }
          dispatch(MessageActionType.messageHistoryRetrieved(messageByChannelId: payloadResponse))
          completion(.success(payloadResponse))
        case let .failure(error):
          dispatch(MessageActionType.errorFetchingMessageHistory(error))
          completion(.failure(error))
        }
      }
    }
  }
}
