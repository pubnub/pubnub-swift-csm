//
//  PubNubCSMExtTests.swift
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

final class PubNubCSMExtTests: XCTestCase {
  var testUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner", eTag: "An3knfs23nf")

  var sameEtagUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner",
                              created: Date.distantFuture, eTag: "An3knfs23nf")
  var newerUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner",
                           created: Date.distantFuture, eTag: "Afqvafw")

  var oldestUser = MockUser(id: "TestId", name: "Test User", occupation: "Test Runner",
                            created: Date.distantPast, eTag: "EFsVSDEfw")

  var otherUser = MockUser(id: "OtherId", name: "Test User", occupation: "Test Runner",
                           created: Date.distantFuture, eTag: "EFsVSDEfw")

  func testPubNubObject_CanUpdate() {
    XCTAssertTrue(testUser.canUpdate(to: newerUser),
                  "Should return `true` when parameter value has more recent `Updated` value")
    XCTAssertFalse(newerUser.canUpdate(to: newerUser),
                   "Should return `false` when `Updated` dates are the identical")
    XCTAssertFalse(newerUser.canUpdate(to: oldestUser),
                   "Should return `false` when parameter `Updated` dates is earlier than `self.Updated`")
    XCTAssertFalse(testUser.canUpdate(to: otherUser),
                   "Should return `false` when `id` properties are not equal")
    XCTAssertFalse(testUser.canUpdate(to: sameEtagUser),
                   "Should return `false`  when `eTag` properties are not equal")
  }

  func testArrayExt_Update() {
    var users = [MockUser]()

    // Append
    XCTAssertNil(users.update(testUser))
    XCTAssertEqual(users, [testUser])

    // Update
    XCTAssertEqual(users.update(newerUser), testUser)
    XCTAssertEqual(users, [newerUser])

    // Duplicate
    XCTAssertNil(users.update(newerUser))
    XCTAssertEqual(users, [newerUser])

    // Ignored
    XCTAssertNil(users.update(oldestUser))
    XCTAssertEqual(users, [newerUser])
  }

  func testArrayExt_UpdateContentOf() {
    var users = [MockUser]()

    // Append
    XCTAssertEqual(users.update(contentsOf: [oldestUser]), [])
    XCTAssertEqual(users, [oldestUser])

    // Update
    XCTAssertEqual(users.update(contentsOf: [testUser, newerUser]), [oldestUser, testUser])
    XCTAssertEqual(users, [newerUser])

    // Duplicate
    XCTAssertEqual(users.update(contentsOf: [newerUser]), [])
    XCTAssertEqual(users, [newerUser])

    // Ignored
    XCTAssertEqual(users.update(contentsOf: [oldestUser]), [])
    XCTAssertEqual(users, [newerUser])
  }

  func testDictionaryExt_UpdatePubNub() {
    var usersById = [String: MockUser]()

    // Append
    XCTAssertNil(usersById.updatePubNub(testUser, forKey: testUser.id))
    XCTAssertEqual(usersById[testUser.id], testUser)

    // Update
    XCTAssertEqual(usersById.updatePubNub(newerUser, forKey: testUser.id), testUser)
    XCTAssertEqual(usersById[testUser.id], newerUser)

    // Duplicate
    XCTAssertNil(usersById.updatePubNub(newerUser, forKey: testUser.id))
    XCTAssertEqual(usersById[testUser.id], newerUser)

    // Ignored
    XCTAssertNil(usersById.updatePubNub(oldestUser, forKey: testUser.id))
    XCTAssertEqual(usersById[testUser.id], newerUser)

    // Missing Key
    XCTAssertNil(usersById.updatePubNub(oldestUser, forKey: "Not A Key"))
    XCTAssertEqual(usersById[testUser.id], newerUser)
  }
}
