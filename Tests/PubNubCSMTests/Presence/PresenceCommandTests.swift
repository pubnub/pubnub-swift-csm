//
//  PresenceCommandTests.swift
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

final class PresenceCommandTests: XCTestCase {
  var provider = PubNubServiceProvider.shared
  var getState: (() -> PresenceState<MockPresenceState>?) = {
    nil
  }

  let mockChannelId = "TestChannelId"
  let mockUserId = "MockUserId"

  override func tearDown() {
    super.tearDown()
    provider.set(service: nil)
  }

  // swiftlint:disable:next function_body_length
  func testHereNow() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let response = HereNowSingleResponsePayload(
      occupancy: 1,
      occupants: ["MockUserId": ["stateKey": "StateValue"]]
    )

    do {
      provider.set(service: try MockPubNub().customResponse(response))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = FetchHereNowRequest(channels: [mockChannelId])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockPresenceState.self) {
      case let PresenceActionType.fetchingHereNow(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let PresenceActionType
        .hereNowRetrieved(
          (presence as [String: TypedChannelPresencePayload<MockPresenceState>]) as Any,
          totalOccupancy,
          totalChannels
        ):
        XCTAssertEqual(presence, [self.mockChannelId:
            TypedChannelPresencePayload(occupancy: 1, occupants: [self.mockUserId: MockPresenceState()])])
        XCTAssertEqual(totalOccupancy, 1)
        XCTAssertEqual(totalChannels, 1)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = PresenceCommand.hereNow(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.presenceByChannelId.keys.first, self.mockChannelId)
        XCTAssertEqual(payload.presenceByChannelId.values.first?.occupancy, 1)
        XCTAssertEqual(payload.presenceByChannelId.values.first?
          .stateByUserId.mapValues { try? $0?.decodeValue(MockPresenceState.self) },
                       [self.mockUserId: MockPresenceState()])
        XCTAssertEqual(payload.totalOccupancy, 1)
        XCTAssertEqual(payload.totalChannels, 1)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testFetchPresenceState() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let response = SinglePresenceStatePayload(
      uuid: mockUserId,
      channel: mockChannelId,
      payload: ["stateKey": "StateValue"]
    )

    do {
      provider.set(service: try MockPubNub().customResponse(response))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = FetchPresenceStateRequest(uuid: mockUserId, channels: [mockChannelId])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockPresenceState.self) {
      case let PresenceActionType.fetchingPresenceState(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let PresenceActionType.presenceStateRetrieved(userId, (response as [String: MockPresenceState]) as Any):
        XCTAssertEqual(userId, self.mockUserId)
        XCTAssertEqual(response, [self.mockChannelId: MockPresenceState()])
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = PresenceCommand.fetchPresenceState(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.userId, self.mockUserId)
        XCTAssertEqual(payload.stateByChannelId.mapValues { try? $0.decodeValue(MockPresenceState.self) },
                       [self.mockChannelId: MockPresenceState()])
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}
