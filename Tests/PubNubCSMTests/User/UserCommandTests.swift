//
//  UserCommandTests.swift
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

final class UserCommandTests: XCTestCase {
  var provider = PubNubServiceProvider.shared

  var getState: (() -> UserState<MockUser>?) = {
    nil
  }

  var mockUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner", eTag: "An3knfs23nf")

  override func tearDown() {
    super.tearDown()

    provider.set(service: nil)
  }

  // MARK: - Fetch Users

  func testFetchUsers() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubUsersResponsePayload(status: 200, data: [mockUser], totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = ObjectsFetchRequest(start: "StartHere")

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockUser.self) {
      case let UserActionType.startedFetchingUsers(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let UserActionType.usersRetrieved(response as UsersResponsePayload<MockUser>):
        XCTAssertEqual(response.data.map { $0.id }, [self.mockUser].map { $0.id })
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = UserCommand.fetchPubNubUsers(testRequest) { result in
      switch result {
      case let .success(response):
        XCTAssertEqual(response.data.compactMap { try? $0.transcode(into: MockUser.self).id },
                       [self.mockUser].map { $0.id })
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  // MARK: - Fetch User

  func testFetchUser() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubUserResponsePayload(data: mockUser)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = UserIdRequest(userId: mockUser.id)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockUser.self) {
      case let UserActionType.startedFetchingUser(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let UserActionType.userRetrieved(user as MockUser):
        XCTAssertEqual(user.id, self.mockUser.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = UserCommand.fetchPubNubUser(testRequest) { result in
      switch result {
      case let .success(user):
        XCTAssertEqual(try? user.transcode(into: MockUser.self).id, self.mockUser.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  // MARK: - Create User

  func testCreateUser() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubUserResponsePayload(data: mockUser)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = UserRequest(user: mockUser)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockUser.self) {
      case let UserActionType.creatingUser(request):
        XCTAssertEqual(try? request.user.transcode(into: MockUser.self), self.mockUser)
        dispatchExpectation.fulfill()
      case let UserActionType.userCreated(user as MockUser):
        XCTAssertEqual(user.id, self.mockUser.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = UserCommand.createPubNub(testRequest) { result in
      switch result {
      case let .success(user):
        XCTAssertEqual(try? user.transcode(into: MockUser.self).id, self.mockUser.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  // MARK: - Update User

  func testUpdateUser() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubUserResponsePayload(data: mockUser)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = UserRequest(user: mockUser)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockUser.self) {
      case let UserActionType.updatingUser(request):
        XCTAssertEqual(try? request.user.transcode(into: MockUser.self), self.mockUser)
        dispatchExpectation.fulfill()
      case let UserActionType.userUpdated(user as MockUser):
        XCTAssertEqual(user.id, self.mockUser.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }
    let thunk = UserCommand.updatePubNub(testRequest) { result in
      switch result {
      case let .success(user):
        XCTAssertEqual(try? user.transcode(into: MockUser.self).id, self.mockUser.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  // MARK: - Delete User

  func testDeleteUser() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = GenericServicePayloadResponse(status: 200)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let dispatch: (Action) -> Void = { action in
      switch action {
      case let UserActionType.deletingUser(userId):
        XCTAssertEqual(userId, self.mockUser.id)
        dispatchExpectation.fulfill()
      case let UserActionType.userDeleted(userId):
        XCTAssertEqual(userId, self.mockUser.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = UserCommand.delete(mockUser.id) { result in
      switch result {
      case let .success(userId):
        XCTAssertEqual(userId, self.mockUser.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}
