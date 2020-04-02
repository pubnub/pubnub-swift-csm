//
//  PubNubListener.swift
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

public enum PubNubListener {
  public static func createListener(dispatch: @escaping DispatchFunction) -> SubscriptionListener {
    let listener = SubscriptionListener()

    listener.didReceiveSubscription = { eventType in
      switch eventType {
      case let .messageReceived(event):
        dispatch(MessageActionType.receivedMessageEvent(
          channelId: event.channel,
          message: event.payload,
          sentAt: event.timetoken
        ))
      case .signalReceived:
        break
      case let .connectionStatusChanged(connectionEvent):
        NetworkStatusActionType.createListener(dispatch, for: connectionEvent)
      case let .subscriptionChanged(event):
        SubscribeActionType.createListener(dispatch, for: event)
      case let .presenceChanged(event):
        PresenceActionType.createListener(dispatch, for: event)
      case let .userUpdated(event):
        dispatch(UserActionType.userUpdatedEvent(event))
      case let .userDeleted(event):
        dispatch(UserActionType.userDeletedEvent(userId: event.id))
      case let .spaceUpdated(event):
        dispatch(SpaceActionType.spaceUpdatedEvent(event))
      case let .spaceDeleted(event):
        dispatch(SpaceActionType.spaceDeletedEvent(spaceId: event.id))
      case let .membershipAdded(event):
        dispatch(MembershipActionType.userAddedToSpaceEvent(membership: event.asMembership,
                                                            member: event.asMember))
      case let .membershipUpdated(event):
        dispatch(MembershipActionType.userMembershipUpdatedOnSpaceEvent(membership: event.asMembership,
                                                                        member: event.asMember))
      case let .membershipDeleted(event):
        dispatch(MembershipActionType.userRemovedFromSpaceEvent(userId: event.userId, spaceId: event.spaceId))
      case .messageActionAdded:
        break
      case .messageActionRemoved:
        break
      case let .subscribeError(error):
        dispatch(SubscribeActionType.subscriptionError(error))
      }
    }

    return listener
  }
}
