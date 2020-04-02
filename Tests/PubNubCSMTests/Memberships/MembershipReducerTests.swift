//
//  MembershipReducerTests.swift
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

final class MembershipReducerTests: XCTestCase {
  var mockMembershipState: MembershipState<MockMembership> = .init()

  let testUserId = "UserId"
  let mockMembership = MockMembership(spaceId: "MembershipID", space: nil, isModerator: true, eTag: "MembershipEtag")

  override func tearDown() {
    super.tearDown()
    // Reset State after every test
    mockMembershipState = .init()
  }

  func testMembersRetrievedAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.membershipsRetrieved(userId: testUserId, response: response, spaces: [])

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [mockMembership])
  }

  func testSpacesJoinedAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.spacesJoined(userId: testUserId, response: response, spaces: [])

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [mockMembership])
  }

  func testMembersUpdatedAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.membershipsUpdated(userId: testUserId, response: response, spaces: [])

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [mockMembership])
  }

  func testSpacesLeftAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.spacesLeft(userId: testUserId, response: response, spaces: [])

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [mockMembership])
  }

  func testUserAddedToSpaceEventAction() {
    let event = MembershipEvent(
      userId: testUserId, spaceId: mockMembership.spaceId, custom: mockMembership.custom,
      created: mockMembership.created, updated: mockMembership.updated, eTag: mockMembership.eTag
    )

    let action = MembershipActionType.userAddedToSpaceEvent(membership: event.asMembership, member: event.asMember)

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [mockMembership])
  }

  func testUserMembershipUpdatedOnSpaceEventAction() {
    let event = MembershipEvent(
      userId: testUserId, spaceId: mockMembership.spaceId, custom: mockMembership.custom,
      created: mockMembership.created, updated: mockMembership.updated, eTag: mockMembership.eTag
    )

    let action = MembershipActionType.userMembershipUpdatedOnSpaceEvent(
      membership: event.asMembership,
      member: event.asMember
    )

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [mockMembership])
  }

  func testUserRemovedFromSpaceEventAction() {
    mockMembershipState.membershipsByUserId[testUserId] = [mockMembership]

    XCTAssertNotNil(mockMembershipState.membershipsByUserId[testUserId])

    let action = MembershipActionType.userRemovedFromSpaceEvent(userId: testUserId, spaceId: mockMembership.spaceId)

    MembershipReducer.reducer(action, state: &mockMembershipState)

    XCTAssertEqual(mockMembershipState.membershipsByUserId[testUserId], [])
  }
}
