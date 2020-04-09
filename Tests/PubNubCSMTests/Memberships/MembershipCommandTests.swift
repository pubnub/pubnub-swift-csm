//
//  MembershipCommandTests.swift
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
import ReSwift

import XCTest

final class MembershipCommandTests: XCTestCase {
  var provider = PubNubServiceProvider.shared

  var getState: (() -> MembershipState<MockMembership>?) = {
    nil
  }

  var mockUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner", eTag: "An3knfs23nf")

  var mockSpace = MockSpace(id: "TestId", name: "Test Space", purpose: "A Testable Space",
                            location: "Local", updated: nil, eTag: "An3knfs23nf")

  override func tearDown() {
    super.tearDown()
    provider.set(service: nil)
  }

  func testFetchMemberships() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMembership = MockMembership(spaceId: mockSpace.id, space: mockSpace,
                                        isModerator: true, eTag: "MembershipEtag")
    let mockResponse = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                        totalCount: 1, next: nil, prev: nil)
    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MembershipFetchRequest(userId: mockUser.id)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case let MembershipActionType.startedFetchingMemberships(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let MembershipActionType.membershipsRetrieved(
        userId, response as MembershipsResponsePayload<MockMembership>, spaces
      ):
        XCTAssertEqual(userId, self.mockUser.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMembership.id])
        XCTAssertEqual(spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MembershipCommand.fetchPubNubMemberships(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.userId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMembership.self).id },
                       [mockMembership.id])
        XCTAssertEqual(payload.spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testJoinMemberships() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMembership = MockMembership(spaceId: mockSpace.id, space: mockSpace,
                                        isModerator: true, eTag: "MembershipEtag")
    let mockResponse = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                        totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MembershipModifyRequest(userId: mockUser.id, modifiedBy: [mockMembership])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case let MembershipActionType.startedJoiningSpaces(request):
        XCTAssertEqual(request.userId, testRequest.userId)
        XCTAssertEqual(request.modifiedBy.compactMap { try? $0.transcode(into: MockMembership.self) }, [mockMembership])
        dispatchExpectation.fulfill()
      case let MembershipActionType.spacesJoined(
        userId, response as MembershipsResponsePayload<MockMembership>, spaces
      ):
        XCTAssertEqual(userId, self.mockUser.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMembership.id])
        XCTAssertEqual(spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MembershipCommand.join(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.userId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMembership.self).id },
                       [mockMembership.id])
        XCTAssertEqual(payload.spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testUpdateMemberships() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMembership = MockMembership(spaceId: mockSpace.id, space: mockSpace,
                                        isModerator: true, eTag: "MembershipEtag")
    let mockResponse = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                        totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MembershipModifyRequest(userId: mockUser.id, modifiedBy: [mockMembership])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case let MembershipActionType.startedUpdatingMemberships(request):
        XCTAssertEqual(request.userId, testRequest.userId)
        XCTAssertEqual(request.modifiedBy.compactMap { try? $0.transcode(into: MockMembership.self) }, [mockMembership])
        dispatchExpectation.fulfill()
      case let MembershipActionType.membershipsUpdated(
        userId, response as MembershipsResponsePayload<MockMembership>, spaces
      ):
        XCTAssertEqual(userId, self.mockUser.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMembership.id])
        XCTAssertEqual(spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MembershipCommand.update(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.userId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMembership.self).id },
                       [mockMembership.id])
        XCTAssertEqual(payload.spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  // swiftlint:disable:next function_body_length
  func testLeaveMemberships() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMembership = MockMembership(spaceId: mockSpace.id, space: mockSpace,
                                        isModerator: true, eTag: "MembershipEtag")
    let mockResponse = PubNubMembershipsResponsePayload(status: 200, data: [mockMembership],
                                                        totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MembershipModifyRequest(userId: mockUser.id, modifiedBy: [mockMembership])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMembership.self) {
      case let MembershipActionType.startedLeavingSpaces(request):
        XCTAssertEqual(request.userId, testRequest.userId)
        XCTAssertEqual(request.modifiedBy.compactMap { try? $0.transcode(into: MockMembership.self) }, [mockMembership])
        dispatchExpectation.fulfill()
      case let MembershipActionType.spacesLeft(
        userId,
        response as MembershipsResponsePayload<MockMembership>,
        _,
        spaces
      ):
        XCTAssertEqual(userId, self.mockUser.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMembership.id])
        XCTAssertEqual(spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MembershipCommand.leave(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.userId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMembership.self).id },
                       [mockMembership.id])
        XCTAssertEqual(payload.spaces.compactMap { try? $0.transcode(into: MockSpace.self).id }, [self.mockSpace.id])
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}
