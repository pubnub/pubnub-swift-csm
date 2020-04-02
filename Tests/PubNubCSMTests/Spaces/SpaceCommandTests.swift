//
//  SpaceCommandTests.swift
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

final class SpaceCommandTests: XCTestCase {
  var provider = PubNubServiceProvider.shared

  var getState: (() -> SpaceState<MockSpace>?) = {
    nil
  }

  var mockSpace = MockSpace(
    id: "TestId", name: "Test Space", purpose: "A Testable Space",
    location: "Local", updated: nil, eTag: "An3knfs23nf"
  )

  override func tearDown() {
    super.tearDown()

    provider.set(service: nil)
  }
}

// MARK: - Fetch Spaces

extension SpaceCommandTests {
  func testFetchSpaces() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubSpacesResponsePayload(status: 200, data: [mockSpace], totalCount: 1, next: nil, prev: nil)

    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = ObjectsFetchRequest(start: "StartHere")

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.startedFetchingSpaces(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let SpaceActionType.spacesRetrieved(response as SpacesResponsePayload<MockSpace>):
        XCTAssertEqual(response.data.map { $0.id }, [self.mockSpace].map { $0.id })
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.fetchPubNubSpaces(testRequest) { result in
      switch result {
      case let .success(response):
        XCTAssertEqual(response.data.compactMap { try? $0.transcode(into: MockSpace.self).id },
                       [self.mockSpace].map { $0.id })
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testFetchSpacesError() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    var responseError: PubNubError?
    do {
      let (pubnub, error) = try MockPubNub().errorForReason(.internalServiceError)
      responseError = error
      provider.set(service: pubnub)
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = ObjectsFetchRequest(start: "StartHere")

    let dispatch: (Action) -> Void = { action in
      switch action {
      case let SpaceActionType.startedFetchingSpaces(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let SpaceActionType.errorFetchingSpaces(error as PubNubError):
        XCTAssertEqual(error, responseError)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.fetchPubNubSpaces(testRequest) { result in
      switch result {
      case let .success(response):
        XCTFail("\(response) should not have been returned")
      case let .failure(error as PubNubError):
        XCTAssertEqual(error, responseError)
      case let .failure(error):
        XCTFail("\(error) not of type `MockType` should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}

// MARK: - Fetch Space

extension SpaceCommandTests {
  func testFetchSpace() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubSpaceResponsePayload(data: mockSpace)
    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SpaceIdRequest(spaceId: mockSpace.id)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.startedFetchingSpace(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let SpaceActionType.spaceRetrieved(space as MockSpace):
        XCTAssertEqual(space.id, self.mockSpace.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.fetchPubNubSpace(testRequest) { result in
      switch result {
      case let .success(space):
        XCTAssertEqual(try? space.transcode(into: MockSpace.self).id, self.mockSpace.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testFetchSpaceError() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    var responseError: PubNubError?
    do {
      let (pubnub, error) = try MockPubNub().errorForReason(.internalServiceError)
      responseError = error
      provider.set(service: pubnub)
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SpaceIdRequest(spaceId: mockSpace.id)

    let dispatch: (Action) -> Void = { action in
      switch action {
      case let SpaceActionType.startedFetchingSpace(request):
        XCTAssertEqual(request, testRequest)
        dispatchExpectation.fulfill()
      case let SpaceActionType.errorFetchingSpace(error as PubNubError):
        XCTAssertEqual(error, responseError)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.fetchPubNubSpace(testRequest) { result in
      switch result {
      case let .success(response):
        XCTFail("\(response) should not have been returned")
      case let .failure(error as PubNubError):
        XCTAssertEqual(error, responseError)
      case let .failure(error):
        XCTFail("\(error) not of type `MockType` should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}

// MARK: - Create Space

extension SpaceCommandTests {
  func testCreateSpace() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubSpaceResponsePayload(data: mockSpace)
    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SpaceRequest(space: mockSpace)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.creatingSpace(request):
        XCTAssertEqual(try? request.space.transcode(into: MockSpace.self), self.mockSpace)
        dispatchExpectation.fulfill()
      case let SpaceActionType.spaceCreated(space as MockSpace):
        XCTAssertEqual(space.id, self.mockSpace.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.createPubNub(testRequest) { result in
      switch result {
      case let .success(space):
        XCTAssertEqual(try? space.transcode(into: MockSpace.self).id, self.mockSpace.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testCreateSpaceError() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    var responseError: PubNubError?
    do {
      let (pubnub, error) = try MockPubNub().errorForReason(.internalServiceError)
      responseError = error
      provider.set(service: pubnub)
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SpaceRequest(space: mockSpace)

    let dispatch: (Action) -> Void = { action in
      switch action {
      case let SpaceActionType.creatingSpace(request):
        XCTAssertEqual(try? request.space.transcode(into: MockSpace.self), self.mockSpace)
        dispatchExpectation.fulfill()
      case let SpaceActionType.errorCreatingSpace(error as PubNubError):
        XCTAssertEqual(error, responseError)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.createPubNub(testRequest) { result in
      switch result {
      case let .success(response):
        XCTFail("\(response) should not have been returned")
      case let .failure(error as PubNubError):
        XCTAssertEqual(error, responseError)
      case let .failure(error):
        XCTFail("\(error) not of type `MockType` should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}

// MARK: - Update Space

extension SpaceCommandTests {
  func testUpdateSpace() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = PubNubSpaceResponsePayload(data: mockSpace)
    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SpaceRequest(space: mockSpace)

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.updatingSpace(request):
        XCTAssertEqual(try? request.space.transcode(into: MockSpace.self), self.mockSpace)
        dispatchExpectation.fulfill()
      case let SpaceActionType.spaceUpdated(space as MockSpace):
        XCTAssertEqual(space.id, self.mockSpace.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.updatePubNub(testRequest) { result in
      switch result {
      case let .success(space):
        XCTAssertEqual(try? space.transcode(into: MockSpace.self).id, self.mockSpace.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testUpdateSpaceError() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    var responseError: PubNubError?
    do {
      let (pubnub, error) = try MockPubNub().errorForReason(.internalServiceError)
      responseError = error
      provider.set(service: pubnub)
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let testRequest = SpaceRequest(space: mockSpace)

    let dispatch: (Action) -> Void = { action in
      switch action {
      case let SpaceActionType.updatingSpace(request):
        XCTAssertEqual(try? request.space.transcode(into: MockSpace.self), self.mockSpace)
        dispatchExpectation.fulfill()
      case let SpaceActionType.errorUpdatingSpace(error as PubNubError):
        XCTAssertEqual(error, responseError)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }

    let thunk = SpaceCommand.updatePubNub(testRequest) { result in
      switch result {
      case let .success(response):
        XCTFail("\(response) should not have been returned")
      case let .failure(error as PubNubError):
        XCTAssertEqual(error, responseError)
      case let .failure(error):
        XCTFail("\(error) not of type `MockType` should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }
}

// MARK: - Delete Space

extension SpaceCommandTests {
  func testDeleteSpace() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    let mockResponse = GenericServicePayloadResponse(status: 200)
    do {
      provider.set(service: try MockPubNub().customResponse(mockResponse))
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let dispatch: (Action) -> Void = { action in
      guard let action = action as? PubNubActionType else {
        XCTFail("Could not convert general `Action` into `PubNubActionType`")
        return
      }

      switch action.transcode(into: MockSpace.self) {
      case let SpaceActionType.deletingSpace(spaceId):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        dispatchExpectation.fulfill()
      case let SpaceActionType.spaceDeleted(spaceId):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }
    let thunk = SpaceCommand.delete(mockSpace.id) { result in
      switch result {
      case let .success(spaceId):
        XCTAssertEqual(spaceId, self.mockSpace.id)
      case let .failure(error):
        XCTFail("\(error) should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  func testDeleteSpaceError() {
    let dispatchExpectation = expectation(description: "Start Action Dispatch")
    let resultExpectation = expectation(description: "Result Action Dispatch")
    let closureExpectation = expectation(description: "Closure Dispatch")

    var responseError: PubNubError?
    do {
      let (pubnub, error) = try MockPubNub().errorForReason(.internalServiceError)
      responseError = error
      provider.set(service: pubnub)
    } catch { XCTFail("Failed to create mock pubnub due to \(error)") }

    let dispatch: (Action) -> Void = { action in
      switch action {
      case let SpaceActionType.deletingSpace(spaceId):
        XCTAssertEqual(spaceId, self.mockSpace.id)
        dispatchExpectation.fulfill()
      case let SpaceActionType.errorDeletingSpace(error as PubNubError):
        XCTAssertEqual(error, responseError)
        resultExpectation.fulfill()
      default:
        XCTFail("\(action) should not have been fired")
      }
    }
    let thunk = SpaceCommand.delete(mockSpace.id) { result in
      switch result {
      case let .success(response):
        XCTFail("\(response) should not have been returned")
      case let .failure(error as PubNubError):
        XCTAssertEqual(error, responseError)
      case let .failure(error):
        XCTFail("\(error) not of type `MockType` should not have been returned")
      }

      closureExpectation.fulfill()
    }

    thunk.body(dispatch, getState, PubNubServiceProvider.shared.context)

    wait(for: [dispatchExpectation, resultExpectation, closureExpectation], timeout: 1.0)
  }

  // swiftlint:disable:next file_length
}
