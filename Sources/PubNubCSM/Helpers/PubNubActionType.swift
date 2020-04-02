//
//  PubNubAction.swift
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

import PubNub

import ReSwift

public protocol PubNubActionType: Action {
  func transcode<T: HashablePubNubUser>(into: T.Type) -> PubNubActionType
  func transcode<T: HashablePubNubSpace>(into: T.Type) -> PubNubActionType
  func transcode<T: HashablePubNubMembership>(into: T.Type) -> PubNubActionType
  func transcode<T: HashablePubNubMember>(into: T.Type) -> PubNubActionType
  func transcode<T: HashablePubNubMessageEnvelop>(into: T.Type) -> PubNubActionType
  func transcode<T: HashablePrecenseStateJSON>(into: T.Type) -> PubNubActionType
}

public extension PubNubActionType {
  func transcode<T: HashablePubNubUser>(into _: T.Type) -> PubNubActionType {
    return self
  }

  func transcode<T: HashablePubNubSpace>(into _: T.Type) -> PubNubActionType {
    return self
  }

  func transcode<T: HashablePubNubMembership>(into _: T.Type) -> PubNubActionType {
    return self
  }

  func transcode<T: HashablePubNubMember>(into _: T.Type) -> PubNubActionType {
    return self
  }

  func transcode<T: HashablePubNubMessageEnvelop>(into _: T.Type) -> PubNubActionType {
    return self
  }

  func transcode<T: HashablePrecenseStateJSON>(into _: T.Type) -> PubNubActionType {
    return self
  }
}
