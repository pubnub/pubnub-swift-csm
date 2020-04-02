//
//  NetworkStatusAction.swift
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

public enum NetworkStatusActionType: PubNubActionType {
  case networkUp
  case networkConnecting
  case networkDown
}

// MARK: - State

public enum NetworkStatus: Hashable {
  case notConnected
  case connecting
  case connected
}

public struct NetworkStatusState: StateType, Hashable {
  public var isConnected: NetworkStatus

  public init(isConnected: NetworkStatus = .notConnected) {
    self.isConnected = isConnected
  }
}

// MARK: - Reducers

public struct NetworkStatusReducer {
  public static func reducer(_ action: PubNubActionType, state: inout NetworkStatusState) {
    if let action = action as? NetworkStatusActionType {
      switch action {
      case .networkUp:
        state.isConnected = .connected
      case .networkConnecting:
        state.isConnected = .connecting
      case .networkDown:
        state.isConnected = .notConnected
      }
    }
  }
}

// MARK: - Listener

extension NetworkStatusActionType {
  public static func createListener(
    _ dispatch: TypedDispatchFunction<NetworkStatusActionType>,
    for event: ConnectionStatus
  ) {
    switch event {
    case .connecting:
      dispatch(.networkConnecting)
    case .connected:
      dispatch(.networkUp)
    case .reconnecting:
      dispatch(.networkConnecting)
    case .disconnected:
      dispatch(.networkDown)
    case .disconnectedUnexpectedly:
      dispatch(.networkDown)
    }
  }
}
