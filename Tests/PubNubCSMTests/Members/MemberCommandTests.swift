//
//  MemberCommandTests.swift
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

final class MemberCommandTests: XCTestCase {
  var provider = PubNubServiceProvider.shared

  var getState: (() -> MemberState<MockMember>?) = {
    nil
  }

  var mockUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner", eTag: "An3knfs23nf")
  var mockSpace = MockSpace(id: "TestId", name: "Test Space", purpose: "A Testable Space",
                            location: "Local", updated: nil, eTag: "An3knfs23nf")

  override func tearDown() {
    super.tearDown()
    provider.set(service: nil)
  }

  func testFetchMembers() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: mockUser, isModerator: true, eTag: "MemberEtag")
    let mockResponse = PubNubMembersResponsePayload(status: 200, data: [mockMember],
                                                    totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MemberFetchRequest(spaceId: mockSpace.id)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMember.self) {
      case let MemberActionType.startedFetchingMembers(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let MemberActionType.membersRetrieved(spaceId, response as MembersResponsePayload<MockMember>, users):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMember].map { $0.id })
        XCTAssertEqual(users.compactMap { try? $0.transcode(into: MockUser.self).id }, [self.mockUser].map { $0.id })
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MemberCommand.fetchMembers(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.spaceId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMember.self).id },
                       [mockMember].map { $0.id })
        XCTAssertEqual(payload.users.compactMap { try? $0.transcode(into: MockUser.self).id },
                       [self.mockUser].map { $0.id })
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testAddMembers() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: mockUser, isModerator: true, eTag: "MemberEtag")
    let mockResponse = PubNubMembersResponsePayload(status: 200, data: [mockMember],
                                                    totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MemberModifyRequest(spaceId: mockSpace.id, modifiedBy: [mockMember])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMember.self) {
      case let MemberActionType.startedAddingMembers(request):
        XCTAssertEqual(request.spaceId, testRequest.spaceId)
        XCTAssertEqual(request.modifiedBy.compactMap { try? $0.transcode(into: MockMember.self) }, [mockMember])
        dispatchExpectation.fulfill()
      case let MemberActionType.membersAdded(spaceId, response as MembersResponsePayload<MockMember>, users):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMember].map { $0.id })
        XCTAssertEqual(users.compactMap { try? $0.transcode(into: MockUser.self).id }, [self.mockUser].map { $0.id })
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MemberCommand.add(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.spaceId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMember.self).id },
                       [mockMember].map { $0.id })
        XCTAssertEqual(payload.users.compactMap { try? $0.transcode(into: MockUser.self).id },
                       [self.mockUser].map { $0.id })
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testUpdateMembers() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: mockUser, isModerator: true, eTag: "MemberEtag")
    let mockResponse = PubNubMembersResponsePayload(status: 200, data: [mockMember],
                                                    totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = MemberModifyRequest(spaceId: mockSpace.id, modifiedBy: [mockMember])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMember.self) {
      case let MemberActionType.startedUpdatingMembers(request):
        XCTAssertEqual(request.spaceId, testRequest.spaceId)
        XCTAssertEqual(request.modifiedBy.compactMap { try? $0.transcode(into: MockMember.self) }, [mockMember])
        dispatchExpectation.fulfill()
      case let MemberActionType.membersUpdated(spaceId, response as MembersResponsePayload<MockMember>, users):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMember].map { $0.id })
        XCTAssertEqual(users.compactMap { try? $0.transcode(into: MockUser.self).id }, [self.mockUser].map { $0.id })
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MemberCommand.update(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.spaceId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMember.self).id },
                       [mockMember].map { $0.id })
        XCTAssertEqual(payload.users.compactMap { try? $0.transcode(into: MockUser.self).id },
                       [self.mockUser].map { $0.id })
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testRemoveMembers() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockMember = MockMember(userId: mockUser.id, user: mockUser, isModerator: true, eTag: "MemberEtag")
    let mockResponse = PubNubMembersResponsePayload(status: 200, data: [mockMember],
                                                    totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }
    let testRequest = MemberModifyRequest(spaceId: mockSpace.id, modifiedBy: [mockMember])

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockMember.self) {
      case let MemberActionType.startedRemovingMembers(request):
        XCTAssertEqual(request.spaceId, testRequest.spaceId)
        XCTAssertEqual(request.modifiedBy.compactMap { try? $0.transcode(into: MockMember.self) }, [mockMember])
        dispatchExpectation.fulfill()
      case let MemberActionType.membersRemoved(spaceId, response as MembersResponsePayload<MockMember>, users):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        XCTAssertEqual(response.data.map { $0.id }, [mockMember].map { $0.id })
        XCTAssertEqual(users.compactMap { try? $0.transcode(into: MockUser.self).id }, [self.mockUser].map { $0.id })
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = MemberCommand.remove(testRequest) { result in
      switch result {
      case let .success(payload):
        XCTAssertEqual(payload.spaceId, self.mockUser.id)
        XCTAssertEqual(payload.response.data.compactMap { try? $0.transcode(into: MockMember.self).id },
                       [mockMember].map { $0.id })
        XCTAssertEqual(payload.users.compactMap { try? $0.transcode(into: MockUser.self).id },
                       [self.mockUser].map { $0.id })
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}
