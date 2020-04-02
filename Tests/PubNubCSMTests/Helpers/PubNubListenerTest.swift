//
//  PubNubListenerTest.swift
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

@testable import PubNub
@testable import PubNubCSM

import ReSwift

import XCTest

final class PubNubListenerTest: XCTestCase {
  var mockSpace = MockSpace(id: "TestId", name: "Test Space",
                            purpose: "A Testable Space", location: "Local", eTag: "An3knfs23nf")
  var mockUser = MockUser(id: "TestId", name: "Test User",
                          occupation: "Test Runner", eTag: "An3knfs23nf")
  let mockMessage = MockMessage(channel: "TestChannelId",
                                message: .init(content: "Test Message"),
                                at: 15_840_560_678_861_627)
}

extension PubNubListenerTest {
  func testMessageReceieved() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let event = MockMessageEvent(payload: mockMessage.message,
                                 channel: mockMessage.channel,
                                 timetoken: mockMessage.timetoken)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMessage.self) {
      case let MessageActionType.receivedMessageEvent(channelId, payload as MockMessagePayload, timetoken):
        XCTAssertEqual(channelId, self.mockMessage.channel)
        XCTAssertEqual(payload, self.mockMessage.message)
        XCTAssertEqual(timetoken, self.mockMessage.timetoken)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .messageReceived(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testConnectionStatusChanged() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let event = ConnectionStatus.connected

    let dispatch: (Action) -> Void = { action in

      switch action {
      case NetworkStatusActionType.networkUp:
        dispatchExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .connectionStatusChanged(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testSubscriptionChanged() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let channel = PubNubChannel(id: "TestId")
    let event = SubscriptionChangeEvent.subscribed(channels: [channel], groups: [])

    let dispatch: (Action) -> Void = { action in

      switch action {
      case let SubscribeActionType.subscribedEvent(channels, groups):
        XCTAssertEqual(channels, [channel])
        XCTAssertEqual(groups, [])
      default:
        XCTFail("\(action) should not have been fired")
      }
      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .subscriptionChanged(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testUserUpdatedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let updatedUser = MockUser(id: mockUser.id, name: "Updated Name", occupation: "New Occupation",
                               created: mockUser.created, updated: Date(), eTag: "UpdatedEtag")

    let event = UserEvent(
      id: mockUser.id, updated: updatedUser.updated, eTag: updatedUser.eTag,
      changes: [.name(updatedUser.name),
                .custom(["occupation": .init(stringValue: "New Occupation")])]
    )

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockUser.self) {
      case let UserActionType.userUpdatedEvent(patch):
        XCTAssertEqual(try? patch.update(self.mockUser), updatedUser)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .userUpdated(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testUserDeletedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let event = IdentifierEvent(id: mockUser.id)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockUser.self) {
      case let UserActionType.userDeletedEvent(userId):
        XCTAssertEqual(userId, self.mockUser.id)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .userDeleted(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testSpaceUpdatedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let updatedSpace = MockSpace(id: mockSpace.id, name: "Test Space", purpose: "Updated Reason",
                                 created: mockSpace.created, updated: Date(), eTag: "UpdatedEtag")

    let event = SpaceEvent(
      id: mockSpace.id, updated: updatedSpace.updated, eTag: updatedSpace.eTag,
      changes: [.name(updatedSpace.name),
                .spaceDescription(updatedSpace.purpose),
                .custom(["location": .init(stringValue: nil)])]
    )

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.spaceUpdatedEvent(patch):
        XCTAssertEqual(try? patch.update(self.mockSpace), updatedSpace)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .spaceUpdated(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testSpaceDeletedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let event = IdentifierEvent(id: mockSpace.id)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.spaceDeletedEvent(userId):
        XCTAssertEqual(userId, self.mockSpace.id)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .spaceDeleted(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testMembershipAddedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: nil, isModerator: true, eTag: "AFn2feN2fx")
    let mockMembership = MockMembership(spaceId: mockSpace.id, space: nil, isModerator: true,
                                        created: mockMember.created, eTag: "AFn2feN2fx")

    let event = MembershipEvent(userId: mockUser.id, spaceId: mockSpace.id, custom: mockMembership.custom,
                                created: mockMember.created, eTag: "AFn2feN2fx")

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case MembershipActionType.userAddedToSpaceEvent(let membership as MockMembership, _):
        XCTAssertEqual(membership, mockMembership)
      default:
        XCTFail("\(action) should not have been fired")
      }

      switch action.transcode(into: MockMember.self) {
      case let MembershipActionType.userAddedToSpaceEvent(_, member as MockMember):
        XCTAssertEqual(member, mockMember)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .membershipAdded(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testMembershipUpdatedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: nil, isModerator: true, eTag: "AFn2feN2fx")
    let mockMembership = MockMembership(spaceId: mockSpace.id, space: nil, isModerator: true,
                                        created: mockMember.created, eTag: "AFn2feN2fx")

    let event = MembershipEvent(userId: mockUser.id, spaceId: mockSpace.id, custom: mockMembership.custom,
                                created: mockMember.created, eTag: "AFn2feN2fx")

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case MembershipActionType.userMembershipUpdatedOnSpaceEvent(let membership as MockMembership, _):
        XCTAssertEqual(membership, mockMembership)
      default:
        XCTFail("\(action) should not have been fired")
      }

      switch action.transcode(into: MockMember.self) {
      case let MembershipActionType.userMembershipUpdatedOnSpaceEvent(_, member as MockMember):
        XCTAssertEqual(member, mockMember)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .membershipUpdated(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testMembershipDeletedEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: nil, isModerator: true, eTag: "AFn2feN2fx")
    let mockMembership = MockMembership(spaceId: mockSpace.id, space: nil, isModerator: true,
                                        created: mockMember.created, eTag: "AFn2feN2fx")

    let event = MembershipIdentifiable(userId: mockMember.userId, spaceId: mockMembership.spaceId)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case let MembershipActionType.userRemovedFromSpaceEvent(_, spaceId):
        XCTAssertEqual(spaceId, mockMembership.id)
      default:
        XCTFail("\(action) should not have been fired")
      }

      switch action.transcode(into: MockMember.self) {
      case MembershipActionType.userRemovedFromSpaceEvent(let userId, _):
        XCTAssertEqual(userId, mockMember.id)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .membershipDeleted(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }

  func testSubscribeErrorEvent() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")

    let event = PubNubError(.badRequest)

    let dispatch: (Action) -> Void = { action in

      switch action {
      case let SubscribeActionType.subscriptionError(error as PubNubError):
        XCTAssertEqual(error, event)
      default:
        XCTFail("\(action) should not have been fired")
      }

      dispatchExpectation.fulfill()
    }

    let listener = PubNubListener.createListener(dispatch: dispatch)

    listener.emitDidReceive(subscription: .subscribeError(event))

    wait(for: [dispatchExpectation], timeout: 1.0)
  }
}
