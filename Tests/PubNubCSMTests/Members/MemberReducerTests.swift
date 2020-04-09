//
//  MemberReducerTests.swift
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

final class MemberReducerTests: XCTestCase {
  var mockMemberState: MemberState<MockMember> = .init()

  let testSpaceID = "TestSpaceID"
  let mockMember = MockMember(userId: "MemberID", user: nil, isModerator: true, eTag: "MemberEtag")

  override func tearDown() {
    super.tearDown()
    // Reset State after every test
    mockMemberState = .init()
  }

  func testMembersRetrievedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersRetrieved(spaceId: testSpaceID, response: response, users: [])

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [mockMember])
  }

  func testSpacesJoinedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersAdded(spaceId: testSpaceID, response: response, users: [])

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [mockMember])
  }

  func testMembersUpdatedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersUpdated(spaceId: testSpaceID, response: response, users: [])

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [mockMember])
  }

  func testSpacesLeftAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersRemoved(spaceId: testSpaceID, response: response,
                                                 removedIds: [mockMember.id], users: [])

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [])
  }

  func testUserAddedToSpaceEventAction() {
    let event = MembershipEvent(
      userId: mockMember.userId, spaceId: testSpaceID, custom: mockMember.custom,
      created: mockMember.created, updated: mockMember.updated, eTag: mockMember.eTag
    )

    let action = MembershipActionType.userAddedToSpaceEvent(membership: event.asMembership, member: event.asMember)

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [mockMember])
  }

  func testUserMembershipUpdatedOnSpaceEventAction() {
    let event = MembershipEvent(
      userId: mockMember.userId, spaceId: testSpaceID, custom: mockMember.custom,
      created: mockMember.created, updated: mockMember.updated, eTag: mockMember.eTag
    )

    let action = MembershipActionType.userMembershipUpdatedOnSpaceEvent(
      membership: event.asMembership,
      member: event.asMember
    )

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [mockMember])
  }

  func testUserRemovedFromSpaceEventAction() {
    mockMemberState.membersBySpaceId[testSpaceID] = [mockMember]

    XCTAssertNotNil(mockMemberState.membersBySpaceId[testSpaceID])

    let action = MembershipActionType.userRemovedFromSpaceEvent(userId: mockMember.userId, spaceId: testSpaceID)

    MemberReducer.reducer(action, state: &mockMemberState)

    XCTAssertEqual(mockMemberState.membersBySpaceId[testSpaceID], [])
  }
}
