//
//  NetworkStatusReducerTests.swift
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

final class NetworkStatusReducerTests: XCTestCase {
  var state = NetworkStatusState()

  func testNetworkUpAction() {
    let action = NetworkStatusActionType.networkUp

    NetworkStatusReducer.reducer(action, state: &state)

    XCTAssertEqual(state.isConnected, .connected)
  }

  func testNetworkConnectingAction() {
    let action = NetworkStatusActionType.networkConnecting

    NetworkStatusReducer.reducer(action, state: &state)

    XCTAssertEqual(state.isConnected, .connecting)
  }

  func testNetworkDownAction() {
    let action = NetworkStatusActionType.networkDown

    NetworkStatusReducer.reducer(action, state: &state)

    XCTAssertEqual(state.isConnected, .notConnected)
  }

  func testListenerConnecting() {
    let status = ConnectionStatus.connecting

    NetworkStatusActionType.createListener({ action in
      XCTAssertEqual(action, NetworkStatusActionType.networkConnecting)
    }, for: status)
  }

  func testListenerConnected() {
    let status = ConnectionStatus.connected

    NetworkStatusActionType.createListener({ action in
      XCTAssertEqual(action, NetworkStatusActionType.networkUp)
    }, for: status)
  }

  func testListenerReconnecting() {
    let status = ConnectionStatus.reconnecting

    NetworkStatusActionType.createListener({ action in
      XCTAssertEqual(action, NetworkStatusActionType.networkConnecting)
    }, for: status)
  }

  func testListenerDisconnected() {
    let status = ConnectionStatus.disconnected

    NetworkStatusActionType.createListener({ action in
      XCTAssertEqual(action, NetworkStatusActionType.networkDown)
    }, for: status)
  }

  func testListenerDisconnectedUnexpectedly() {
    let status = ConnectionStatus.disconnectedUnexpectedly

    NetworkStatusActionType.createListener({ action in
      XCTAssertEqual(action, NetworkStatusActionType.networkDown)
    }, for: status)
  }
}
