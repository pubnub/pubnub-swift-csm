//
//  UserReducerTests.swift
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

final class UserReducerTests: XCTestCase {
  var mockState: UserState<MockUser> = .init()
  var otherState: UserState<UserObject> = .init()

  var mockUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner", eTag: "An3knfs23nf")
  var mockMember = MockMember(userId: "TestMemberId", user: nil, isModerator: true, eTag: "Anf23NAf2")
  var testSpaceId = "TestSpaceId"

  override func tearDown() {
    super.tearDown()

    // Reset State after every test
    mockState = .init()
    otherState = .init()
  }

  func testUsersRetrievedAction() {
    let response = PubNubUsersResponsePayload(status: 200, data: [mockUser], totalCount: 1, next: nil, prev: nil)

    UserReducer.reducer(UserActionType.usersRetrieved(response), state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testUserRetrievedAction() {
    UserReducer.reducer(UserActionType.userRetrieved(mockUser), state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testUserCreatedAction() {
    UserReducer.reducer(UserActionType.userCreated(mockUser), state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testUserUpdatedAction() {
    UserReducer.reducer(UserActionType.userUpdated(mockUser), state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testUserDeletedAction() {
    mockState.users[mockUser.id] = mockUser

    UserReducer.reducer(UserActionType.userDeleted(userId: mockUser.id), state: &mockState)

    XCTAssertNil(mockState.users[mockUser.id])
  }

  func testUserUpdatedEventAction() {
    mockState.users[mockUser.id] = mockUser

    let patch = ObjectPatch<UserChangeEvent>(
      id: mockUser.id,
      updated: Date(),
      eTag: "UpdatedETag",
      changes: [.name("Name Change")]
    )

    UserReducer.reducer(UserActionType.userUpdatedEvent(patch), state: &mockState)

    let patchedMock = try? patch.update(mockUser)

    XCTAssertEqual(mockState.users[mockUser.id], patchedMock)
  }

  func testUserDeletedEventAction() {
    mockState.users[mockUser.id] = mockUser

    UserReducer.reducer(UserActionType.userDeletedEvent(userId: mockUser.id), state: &mockState)

    XCTAssertNil(mockState.users[mockUser.id])
  }

  // MARK: - MemberActionType

  func testMembersRetrievedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersRetrieved(spaceId: testSpaceId, response: response, users: [mockUser])

    UserReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testMembersAddedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersAdded(spaceId: testSpaceId, response: response, users: [mockUser])

    UserReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testMembersUpdatedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersUpdated(spaceId: testSpaceId, response: response, users: [mockUser])

    UserReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  func testMembersRemovedAction() {
    let response = PubNubMembersResponsePayload(status: 200, data: [mockMember], totalCount: nil, next: nil, prev: nil)

    let action = MemberActionType.membersRemoved(spaceId: testSpaceId, response: response,
                                                 removedIds: [mockMember.id], users: [mockUser])

    UserReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.users[mockUser.id], mockUser)
  }

  // MARK: - Ignored Actions

  func testIgnoredPubNubAction() {
    var testState: UserState<MockUser> = .init() {
      didSet {
        XCTAssertEqual(oldValue, testState)
      }
    }

    let action = SpaceActionType.errorCreatingSpace(MockError.responseError)

    UserReducer.reducer(action, state: &testState)

    XCTAssertTrue(testState.users.isEmpty)
  }

  func testIgnoredSpaceActionType() {
    var testState: UserState<MockUser> = .init() {
      didSet {
        XCTAssertEqual(oldValue, testState)
      }
    }

    let action = UserActionType.errorCreatingUser(MockError.responseError)

    UserReducer.reducer(action, state: &testState)

    XCTAssertTrue(testState.users.isEmpty)
  }

  func testMembershipActionTest() {
    var testState: UserState<MockUser> = .init() {
      didSet {
        XCTAssertEqual(oldValue, testState)
      }
    }

    let action = MemberActionType.errorAddingSpaces(MockError.responseError)

    UserReducer.reducer(action, state: &testState)

    XCTAssertTrue(testState.users.isEmpty)
  }
}
