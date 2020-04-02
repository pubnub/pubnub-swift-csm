//
//  SpaceReducerTests.swift
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

final class SpaceReducerTests: XCTestCase {
  var mockState: SpaceState<MockSpace> = .init()
  var otherState: SpaceState<SpaceObject> = .init()

  var mockSpace = MockSpace(
    id: "TestId", name: "Test Space", purpose: "A Testable Space",
    location: "Local", updated: nil, eTag: "An3knfs23nf"
  )

  let mockMembership = MockMembership(spaceId: "TestId", space: nil, isModerator: true, eTag: "MembershipEtag")
  let testUserId = "TestUserId"

  override func tearDown() {
    super.tearDown()

    // Reset State after every test
    mockState = .init()
    otherState = .init()
  }

  func testSpacesRetrievedAction() {
    let response = PubNubSpacesResponsePayload(status: 200, data: [mockSpace], totalCount: 1,
                                               next: nil, prev: nil)

    SpaceReducer.reducer(SpaceActionType.spacesRetrieved(response), state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testSpaceRetrievedAction() {
    SpaceReducer.reducer(SpaceActionType.spaceRetrieved(mockSpace), state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testSpaceCreatedAction() {
    SpaceReducer.reducer(SpaceActionType.spaceCreated(mockSpace), state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testSpaceUpdatedAction() {
    SpaceReducer.reducer(SpaceActionType.spaceUpdated(mockSpace), state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testSpaceDeletedAction() {
    mockState.spaces[mockSpace.id] = mockSpace

    SpaceReducer.reducer(SpaceActionType.spaceDeleted(spaceId: mockSpace.id), state: &mockState)

    XCTAssertNil(mockState.spaces[mockSpace.id])
  }

  func testSpaceUpdatedEventAction() {
    mockState.spaces[mockSpace.id] = mockSpace

    let patch = ObjectPatch<SpaceChangeEvent>(
      id: mockSpace.id,
      updated: Date(),
      eTag: "UpdatedETag",
      changes: [.name("Name Change")]
    )

    SpaceReducer.reducer(SpaceActionType.spaceUpdatedEvent(patch), state: &mockState)

    let patchedMock = try? patch.update(mockSpace)

    XCTAssertEqual(mockState.spaces[mockSpace.id], patchedMock)
  }

  func testSpaceDeletedEventAction() {
    mockState.spaces[mockSpace.id] = mockSpace

    SpaceReducer.reducer(SpaceActionType.spaceDeletedEvent(spaceId: mockSpace.id), state: &mockState)

    XCTAssertNil(mockState.spaces[mockSpace.id])
  }

  // MARK: - MembershipActionType

  func testMembershipsRetrievedAction() {
    let response = PubNubMembershipsResponsePayload(
      status: 200,
      data: [mockMembership],
      totalCount: nil, next: nil, prev: nil
    )

    let action = MembershipActionType.membershipsRetrieved(userId: testUserId, response: response, spaces: [mockSpace])

    SpaceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testSpacesJoinedAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.membershipsRetrieved(userId: testUserId, response: response, spaces: [mockSpace])

    SpaceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testMembershipsUpdatedAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.membershipsRetrieved(userId: testUserId, response: response, spaces: [mockSpace])

    SpaceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  func testSpacesLeftAction() {
    let response = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                    totalCount: nil, next: nil, prev: nil)

    let action = MembershipActionType.membershipsRetrieved(userId: testUserId, response: response, spaces: [mockSpace])

    SpaceReducer.reducer(action, state: &mockState)

    XCTAssertEqual(mockState.spaces[mockSpace.id], mockSpace)
  }

  // MARK: - Ignored Actions

  func testIgnoredPubNubAction() {
    var testState: SpaceState<MockSpace> = .init() {
      didSet {
        XCTAssertEqual(oldValue, testState)
      }
    }

    let action = UserActionType.errorCreatingUser(MockError.responseError)

    SpaceReducer.reducer(action, state: &testState)

    XCTAssertTrue(testState.spaces.isEmpty)
  }

  func testIgnoredSpaceActionType() {
    var testState: SpaceState<MockSpace> = .init() {
      didSet {
        XCTAssertEqual(oldValue, testState)
      }
    }

    let action = SpaceActionType.errorCreatingSpace(MockError.responseError)

    SpaceReducer.reducer(action, state: &testState)

    XCTAssertTrue(testState.spaces.isEmpty)
  }

  func testMembershipActionTest() {
    var testState: SpaceState<MockSpace> = .init() {
      didSet {
        XCTAssertEqual(oldValue, testState)
      }
    }

    let action = MembershipActionType.errorJoiningSpaces(MockError.responseError)

    SpaceReducer.reducer(action, state: &testState)

    XCTAssertTrue(testState.spaces.isEmpty)
  }
}
