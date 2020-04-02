//
//  File.swift
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

// MARK: Member

struct MockMember: HashablePubNubMember {
  var userId: String

  var mockUser: MockUser?
  var user: PubNubUser? {
    get { return mockUser }
    set { mockUser = try? newValue?.transcode(into: MockUser.self) }
  }

  var isModerator: Bool
  var custom: [String: JSONCodableScalar]? {
    return ["isModerator": isModerator]
  }

  var created: Date
  var updated: Date
  var eTag: String

  init(
    userId: String,
    user: MockUser?,
    isModerator: Bool = false,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String
  ) {
    self.userId = userId
    mockUser = user
    self.isModerator = isModerator
    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag
  }

  init(from member: PubNubMember) throws {
    self.init(
      userId: member.userId,
      user: try? member.user?.transcode(into: MockUser.self),
      isModerator: member.custom?["isModerator"]?.boolOptional ?? false,
      created: member.created,
      updated: member.updated,
      eTag: member.eTag
    )
  }
}

extension SpaceObjectMember: Hashable {
  public func hash(into _: inout Hasher) { /* no-op for conformance */ }
}

// MARK: Membership

struct MockMembership: HashablePubNubMembership {
  var spaceId: String

  var mockSpace: MockSpace?
  var space: PubNubSpace? {
    get { return mockSpace }
    set { mockSpace = try? newValue?.transcode(into: MockSpace.self) }
  }

  var isModerator: Bool
  var custom: [String: JSONCodableScalar]? {
    return ["isModerator": isModerator]
  }

  var created: Date
  var updated: Date
  var eTag: String

  init(
    spaceId: String,
    space: MockSpace?,
    isModerator: Bool = false,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String
  ) {
    self.spaceId = spaceId
    mockSpace = space
    self.isModerator = isModerator
    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag
  }

  init(from membership: PubNubMembership) throws {
    self.init(
      spaceId: membership.spaceId,
      space: try? membership.space?.transcode(into: MockSpace.self),
      isModerator: membership.custom?["isModerator"]?.boolOptional ?? false,
      created: membership.created,
      updated: membership.updated,
      eTag: membership.eTag
    )
  }
}

extension UserObjectMembership: Hashable {
  public func hash(into _: inout Hasher) { /* no-op for conformance */ }
}

// MARK: User

struct MockUser: HashablePubNubUser {
  var id: String
  var name: String
  var externalId: String?
  var profileURL: String?
  var email: String?

  var occupation: String?
  var custom: [String: JSONCodableScalar]? {
    if let value = occupation {
      return ["occupation": value]
    }
    return nil
  }

  var created: Date
  var updated: Date
  var eTag: String

  init(
    id: String,
    name: String,
    externalId: String? = nil,
    profileURL: String? = nil,
    email: String? = nil,
    occupation: String? = nil,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String
  ) {
    self.id = id
    self.name = name
    self.externalId = externalId
    self.profileURL = profileURL
    self.email = email
    self.occupation = occupation
    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag
  }

  init(from user: PubNubUser) throws {
    self.init(
      id: user.id,
      name: user.name,
      externalId: user.externalId,
      profileURL: user.profileURL,
      email: user.email,
      occupation: user.custom?["occupation"]?.stringOptional,
      created: user.created,
      updated: user.updated,
      eTag: user.eTag
    )
  }
}

extension UserObject: Hashable {
  public func hash(into _: inout Hasher) { /* no-op for conformance */ }
}

// MARK: Space

struct MockSpace: HashablePubNubSpace {
  var id: String
  var name: String
  var purpose: String?

  var spaceDescription: String? {
    return purpose
  }

  var location: String?
  var custom: [String: JSONCodableScalar]? {
    if let value = location {
      return ["location": value]
    }
    return nil
  }

  var created: Date
  var updated: Date
  var eTag: String

  init(
    id: String,
    name: String,
    purpose: String? = nil,
    location: String? = nil,
    created: Date = Date(),
    updated: Date? = nil,
    eTag: String
  ) {
    self.id = id
    self.name = name
    self.purpose = purpose
    self.location = location
    self.created = created
    self.updated = updated ?? created
    self.eTag = eTag
  }

  init(from space: PubNubSpace) throws {
    self.init(
      id: space.id,
      name: space.name,
      purpose: space.spaceDescription,
      location: space.custom?["location"]?.stringOptional,
      created: space.created,
      updated: space.updated,
      eTag: space.eTag
    )
  }
}

extension SpaceObject: Hashable {
  public func hash(into _: inout Hasher) { /* no-op for conformance */ }
}

// MARK: Message

struct MockMessagePayload: JSONCodable, Hashable {
  var type = "text"
  var content: String
}

struct MockMessage: MessageEnvelop, Hashable, Codable {
  var channel: String
  var timetoken: Timetoken
  var message: MockMessagePayload

  init(channel: String, message: MockMessagePayload, at timetoken: Timetoken) {
    self.channel = channel
    self.message = message
    self.timetoken = timetoken
  }
}

struct MockMessageEvent: MessageEvent {
  var publisher: String?
  var payload: AnyJSON
  var channel: String
  var subscription: String?
  var timetoken: Timetoken
  var userMetadata: AnyJSON?
  var messageType: MessageType

  init(
    publisher: String? = nil,
    payload: JSONCodable,
    channel: String,
    subscription: String? = nil,
    timetoken: Timetoken,
    userMetadata: AnyJSON? = nil,
    messageType: MessageType = .message
  ) {
    self.publisher = publisher
    self.payload = payload.codableValue
    self.channel = channel
    self.subscription = subscription
    self.timetoken = timetoken
    self.userMetadata = userMetadata
    self.messageType = messageType
  }
}

// MARK: - Presence

struct MockPresenceEvent: PresenceEvent {
  var channel: String = "MockChannelId"
  var subscriptionMatch: String?
  var senderTimetoken: Timetoken = 0
  var presenceTimetoken: Timetoken = 1
  var metadata: AnyJSON?
  var event: PresenceStateEvent = .join
  var occupancy: Int = 1
  var join: [String] = []
  var leave: [String] = []
  var timeout: [String] = []
  var stateChange: [String: [String: Codable]] = ["MockUserID": ["stateKey": "StateValue"]]
}

struct MockPresenceState: PrecenseStateJSON, Hashable {
  var stateKey: String = "StateValue"
}
