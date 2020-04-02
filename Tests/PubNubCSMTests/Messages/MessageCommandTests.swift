//
//  MessageCommandTests.swift
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
@testable import PubNubCSM

import PubNub
import ReSwift

import XCTest

final class MessageCommandTests: XCTestCase {
  var provider = PubNubServiceProvider.shared
  var getState: (() -> MessageState<MockMessage>?) = {
    nil
  }

  let mockMessage = MockMessage(channel: "TestChannelId",
                                message: .init(content: "Test Message"),
                                at: 15_840_560_678_861_627)

  override func tearDown() {
    super.tearDown()
    provider.set(service: nil)
  }

  func testSendMessage() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let response = PublishResponsePayload(timetoken: mockMessage.timetoken)
    do {
      provider.set(service: try MockPubNub().customResponse(response))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SendMessageRequest(content: mockMessage.message, channel: mockMessage.channel)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMessage.self) {
      case let MessageActionType.sendingMessage(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let MessageActionType.messageSent(channelId, payload as MockMessagePayload, timetoken):
        XCTAssertEqual(channelId, self.mockMessage.channel)
        XCTAssertEqual(payload, self.mockMessage.message)
        XCTAssertEqual(timetoken, self.mockMessage.timetoken)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MessageCommand.sendMessage(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.channelId, self.mockMessage.channel)
        XCTAssertEqual(try? payload.message.codableValue.decode(MockMessagePayload.self), self.mockMessage.message)
        XCTAssertEqual(payload.sentAt, self.mockMessage.timetoken)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testFetchMessageHistory() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let messageResponse = MessageHistoryMessagesPayload(message: mockMessage.message, timetoken: mockMessage.timetoken)
    let channelHistoryResponse = MessageHistoryChannelPayload(messags: [messageResponse])
    let response = MessageHistoryResponse(channels: [mockMessage.channel: channelHistoryResponse])
    do {
      provider.set(service: try MockPubNub().customResponse(response))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MessageHistoryRequest(channels: [mockMessage.channel])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMessage.self) {
      case let MessageActionType.fetchingMessageHistory(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let MessageActionType.messageHistoryRetrieved((response as [String: [MockMessage]]) as Any):
        XCTAssertEqual(response[self.mockMessage.channel], [self.mockMessage])
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MessageCommand.fetchMessageHistory(testRequest) { result in
      switch result {
      case let .success(response):
        let messages = try? response[self.mockMessage.channel]?.compactMap {
          MockMessage(channel: self.mockMessage.channel,
                      message: try $0.decodeMessage(MockMessagePayload.self),
                      at: $0.timetoken)
        }

        XCTAssertEqual(messages, [self.mockMessage])
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}
