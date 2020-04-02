//
//  PresenceReducerTests.swift
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

import XCTest

final class PresenceReducerTests: XCTestCase {
  let mockUserId = "MockUserId"
  let mockChannelId = "MockChannel"

  let mockPresenceState: PrecenseStateJSON = MockPresenceState()
  let mockPresenceJSON: PrecenseJSON = HereNowChannelsPayload(
    occupancy: 1,
    occupants: ["MockUserId": ["stateKey": "StateValue"]]
  )

  let mockTotalOccupancy = 1
  let mockTotalChannels = 1

  var mockState = PresenceState<MockPresenceState>()

  func testHereNowRetrieved() {
    let action = PresenceActionType.hereNowRetrieved(
      presenceByChannelId: [mockChannelId: mockPresenceJSON],
      totalOccupancy: mockTotalOccupancy,
      totalChannels: mockTotalChannels
    )

    PresenceReducer.reducer(action, state: &mockState)

    let payload = TypedChannelPresencePayload(occupancy: 1, occupants: [mockUserId: MockPresenceState()])

    XCTAssertEqual(mockState.presenceByChannelId, [mockChannelId: payload])
    XCTAssertEqual(mockState.totalOccupancy, mockTotalOccupancy)
    XCTAssertEqual(mockState.totalChannels, mockTotalChannels)
  }

  func testPresenceStateRetrieved() {
    let action = PresenceActionType.presenceStateRetrieved(
      userId: mockUserId,
      stateByChannelId: [mockChannelId: mockPresenceState]
    )

    PresenceReducer.reducer(action, state: &mockState)

    let payload = TypedChannelPresencePayload(occupancy: 0, occupants: [mockUserId: MockPresenceState()])

    XCTAssertEqual(mockState.presenceByChannelId, [mockChannelId: payload])
  }

  func testJoinEvent() {
    let action = PresenceActionType.joinEvent(
      channelId: mockChannelId, occupancy: 2, occupantIds: [mockUserId, mockUserId]
    )

    PresenceReducer.reducer(action, state: &mockState)

    let state: [String: MockPresenceState?] = [mockUserId: nil]

    let payload = TypedChannelPresencePayload(occupancy: 2, occupants: state)

    XCTAssertEqual(mockState.presenceByChannelId, [mockChannelId: payload])
  }

  func testLeaveEvent() {
    let state: [String: MockPresenceState?] = [mockUserId: nil]
    let payload = TypedChannelPresencePayload(occupancy: 2, occupants: state)

    mockState.presenceByChannelId = [mockChannelId: payload]

    let action = PresenceActionType.leaveEvent(
      channelId: mockChannelId, occupancy: 0, occupantIds: [mockUserId]
    )

    PresenceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.presenceByChannelId[mockChannelId]?.occupants, [:])
    XCTAssertEqual(mockState.presenceByChannelId[mockChannelId]?.occupancy, 0)
  }

  func testTimeoutEvent() {
    let state: [String: MockPresenceState?] = [mockUserId: nil]
    let payload = TypedChannelPresencePayload(occupancy: 2, occupants: state)

    mockState.presenceByChannelId = [mockChannelId: payload]

    let action = PresenceActionType.timeoutEvent(
      channelId: mockChannelId, occupancy: 0, occupantIds: [mockUserId]
    )

    PresenceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.presenceByChannelId[mockChannelId]?.occupants, [:])
    XCTAssertEqual(mockState.presenceByChannelId[mockChannelId]?.occupancy, 0)
  }

  func testStateChangeEvent() {
    let action = PresenceActionType.stateChangeEvent(
      channelId: mockChannelId, occupancy: 1, stateByUserId: [mockUserId: mockPresenceState]
    )

    PresenceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.presenceByChannelId[mockChannelId]?.occupants, [mockUserId: MockPresenceState()])
    XCTAssertEqual(mockState.presenceByChannelId[mockChannelId]?.occupancy, 1)
  }

//  func testListenerDisconnectedUnexpectedly() {
//
//  }
}
