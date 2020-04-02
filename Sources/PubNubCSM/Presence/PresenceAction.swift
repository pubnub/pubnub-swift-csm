//
//  PresenceAction.swift
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

public enum PresenceActionType: PubNubActionType {
  case fetchingHereNow(FetchHereNowRequest)
  case hereNowRetrieved(presenceByChannelId: [String: PrecenseJSON], totalOccupancy: Int, totalChannels: Int)
  case errorFetchingHereNow(Error)

  case fetchingPresenceState(FetchPresenceStateRequest)
  case presenceStateRetrieved(userId: String, stateByChannelId: [String: PrecenseStateJSON])
  case errorFetchingPresenceState(Error)

  case joinEvent(channelId: String, occupancy: Int, occupantIds: [String])
  case leaveEvent(channelId: String, occupancy: Int, occupantIds: [String])
  case timeoutEvent(channelId: String, occupancy: Int, occupantIds: [String])
  case stateChangeEvent(channelId: String, occupancy: Int, stateByUserId: [String: PrecenseStateJSON])

  public func transcode<T: HashablePrecenseStateJSON>(into _: T.Type) -> PubNubActionType {
    switch self {
    case let .hereNowRetrieved(presenceByChannelId, occupancyCount, channelCount):
      return PresenceActionType.hereNowRetrieved(
        presenceByChannelId: presenceByChannelId.compactMapValues { try? $0.decodeMemberState(T.self) },
        totalOccupancy: occupancyCount,
        totalChannels: channelCount
      )
    case let .presenceStateRetrieved(userId, stateByChannelId):
      return PresenceActionType.presenceStateRetrieved(
        userId: userId,
        stateByChannelId: stateByChannelId.compactMapValues { try? $0.decodeValue(T.self) }
      )
    case let .stateChangeEvent(channelId, occupancy, stateByUserId):
      return PresenceActionType.stateChangeEvent(
        channelId: channelId,
        occupancy: occupancy,
        stateByUserId: stateByUserId.compactMapValues { try? $0.decodeValue(T.self) }
      )
    default:
      break
    }

    return self
  }
}

// MARK: - State

public struct PresenceState<T: HashablePrecenseStateJSON>: StateType, Equatable {
  public var presenceByChannelId: [String: TypedChannelPresencePayload<T>]
  public var totalOccupancy: Int
  public var totalChannels: Int

  public init(
    presenceByChannelId: [String: TypedChannelPresencePayload<T>] = [:],
    totalOccupancy: Int = 0,
    totalChannels: Int = 0
  ) {
    self.presenceByChannelId = presenceByChannelId
    self.totalOccupancy = totalOccupancy
    self.totalChannels = totalChannels
  }
}

// MARK: - Reducer

public struct PresenceReducer {
  public static func reducer<T: HashablePrecenseStateJSON>(_ action: PubNubActionType, state: inout PresenceState<T>) {
    switch action.transcode(into: T.self) {
    case let action as PresenceActionType:
      typedReducer(action, state: &state)
    default:
      break
    }
  }

  static func typedReducer<T: HashablePrecenseStateJSON>(
    _ action: PresenceActionType,
    state: inout PresenceState<T>
  ) {
    switch action {
    case let .hereNowRetrieved(
      (presenceByChannelId as [String: TypedChannelPresencePayload<T>]) as Any,
      totalOccupancy,
      totalChannels
    ):
      state.presenceByChannelId.merge(presenceByChannelId) { $1 }
      state.totalOccupancy = totalOccupancy
      state.totalChannels = totalChannels

    case let .presenceStateRetrieved(userId, (presence as [String: T]) as Any):
      presence.forEach {
        if state.presenceByChannelId[$0.key] == nil {
          state.presenceByChannelId[$0.key] = TypedChannelPresencePayload()
        }
        state.presenceByChannelId[$0.key]?.occupants.updateValue($0.value, forKey: userId)
      }

    case let .joinEvent(channelId, occupancy, userIds):
      if state.presenceByChannelId[channelId] == nil {
        var occupants = [String: T?]()
        userIds.forEach { occupants.updateValue(nil, forKey: $0) }
        state.presenceByChannelId[channelId] = TypedChannelPresencePayload(occupancy: occupancy, occupants: occupants)
      } else {
        state.presenceByChannelId[channelId]?.occupancy = occupancy
        userIds.forEach {
          // Only `join` the user if they're not already present
          if state.presenceByChannelId[channelId]?.occupants[$0] == nil {
            state.presenceByChannelId[channelId]?.occupants.updateValue(nil, forKey: $0)
          }
        }
      }

    case let .leaveEvent(channelId, occupancy, userIds),
         let .timeoutEvent(channelId, occupancy, userIds):
      if state.presenceByChannelId[channelId] == nil {
        state.presenceByChannelId[channelId] = TypedChannelPresencePayload(occupancy: occupancy)
      } else {
        state.presenceByChannelId[channelId]?.occupancy = occupancy
        userIds.forEach { state.presenceByChannelId[channelId]?.occupants.removeValue(forKey: $0) }
      }

    case let .stateChangeEvent(channelId, occupancy, (presence as [String: T]) as Any):
      if state.presenceByChannelId[channelId] == nil {
        state.presenceByChannelId[channelId] = TypedChannelPresencePayload(occupancy: occupancy, occupants: presence)
      } else {
        state.presenceByChannelId[channelId]?.occupancy = occupancy
        state.presenceByChannelId[channelId]?.occupants.merge(presence) { $1 }
      }

    default:
      break
    }
  }
}

// MARK: - Listener

extension PresenceActionType {
  public static func createListener(_ dispatch: TypedDispatchFunction<PresenceActionType>, for event: PresenceEvent) {
    switch event.event {
    case .join:
      dispatch(.joinEvent(channelId: event.channel, occupancy: event.occupancy, occupantIds: event.join))
    case .leave:
      dispatch(.leaveEvent(channelId: event.channel, occupancy: event.occupancy, occupantIds: event.leave))
    case .timeout:
      dispatch(.timeoutEvent(channelId: event.channel, occupancy: event.occupancy, occupantIds: event.timeout))
    case .stateChange:
      dispatch(.stateChangeEvent(
        channelId: event.channel,
        occupancy: event.occupancy,
        stateByUserId: event.memberState
      ))
    case .interval:
      if !event.join.isEmpty {
        dispatch(.joinEvent(channelId: event.channel, occupancy: event.occupancy, occupantIds: event.join))
      }
      if !event.leave.isEmpty {
        dispatch(.leaveEvent(channelId: event.channel, occupancy: event.occupancy, occupantIds: event.leave))
      }
      if !event.timeout.isEmpty {
        dispatch(.timeoutEvent(channelId: event.channel, occupancy: event.occupancy, occupantIds: event.timeout))
      }
      if !event.stateChange.isEmpty {
        dispatch(.stateChangeEvent(
          channelId: event.channel,
          occupancy: event.occupancy,
          stateByUserId: event.memberState
        ))
      }
    }
  }
}
