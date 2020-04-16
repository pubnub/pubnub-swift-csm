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

import PubNub

extension PubNubObject {
  /// Checks if an object is newer than another object based on their respective `Updated` timestamp
  ///  - returns: True if the `Self` object is newer than the other object
  ///
  /// Compares the eTag and updated timestamps to determine which object is more recent
  public func canUpdate(to other: PubNubObject) -> Bool {
    return id == other.id &&
      eTag != other.eTag &&
      updated.timeIntervalSince(other.updated) < 0
  }
}

// MARK: - Array

// MARK: Where Element: PubNubObject

extension Array where Element: PubNubObject {
  @discardableResult mutating func update(_ newElement: Self.Element) -> Self.Element? {
    for (index, element) in enumerated() where element.id == newElement.id {
      if element.canUpdate(to: newElement) {
        self[index] = newElement
        return element
      }
      return nil
    }
    append(newElement)
    return nil
  }

  @discardableResult mutating func update(contentsOf other: [Self.Element]) -> [Self.Element] {
    return other.compactMap { self.update($0) }
  }
}

extension Array where Element: Equatable {
  func deduplicate<Value: Comparable>(
    by keyPath: KeyPath<Element, Value>,
    contentsOf other: Self,
    perserveOriginal: Bool = false
  ) -> [Element] {
    if isEmpty || other.isEmpty {
      return other + self
    }

    var newSelf = self
    var index = endIndex - 1
    let other = other.sorted(by: keyPath)

    // Walk back from end to see where a smart start is
    while self[index][keyPath: keyPath] > other[0][keyPath: keyPath] {
      index -= 1

      if index < startIndex {
        index = startIndex
        break
      }
    }

    // where clause ensures duplicates inside other are removed
    for value in other where value != newSelf[safe: index] {

      // Set any values that are less than current value
      while newSelf[index][keyPath: keyPath] < value[keyPath: keyPath] {
        index += 1

        if index == newSelf.endIndex {
          break
        }
      }

      // If the newValue has matching keypath but is not identical, then replace the existing
      if newSelf[safe: index] != value {
        if index == newSelf.endIndex {
          newSelf.append(value)
        } else if newSelf[index][keyPath: keyPath] == value[keyPath: keyPath] {
          if !perserveOriginal {
            newSelf[index] = value
          }
        } else {
          // Costly, but shouldn't happen often if we normally insert into the end
          newSelf.insert(value, at: index)
        }
      }
    }

    return newSelf
  }

  func containsIndex(_ index: Index) -> Bool {
    index >= startIndex && index < endIndex
  }

  subscript(safe index: Index) -> Element? {
    get {
      guard containsIndex(index) else { return nil }
      return self[index]
    }
    set {
      guard let newValue = newValue else { return }

      switch index {
      case ..<startIndex:
        insert(newValue, at: startIndex)
      case startIndex ... endIndex - 1:
        self[index] = newValue
      default:
        append(newValue)
      }
    }
  }
}

extension Sequence {
  func sorted<Value>(
    by keyPath: KeyPath<Self.Element, Value>,
    using valuesAreInIncreasingOrder: (Value, Value) throws -> Bool
  ) rethrows -> [Self.Element] {
    return try sorted(by: {
      try valuesAreInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
    })
  }

  func sorted<Value: Comparable>(
    by keyPath: KeyPath<Self.Element, Value>) -> [Self.Element] {
    return sorted(by: keyPath, using: <)
  }
}

// MARK: - Dictionary

// MARK: Dictionary Value: PubNubObject

extension Dictionary where Value: PubNubObject {
  @discardableResult mutating func updatePubNub(_ value: Value, forKey key: Key) -> Value? {
    guard let oldValue = self[key] else {
      self[key] = value
      return nil
    }

    if oldValue.canUpdate(to: value) {
      self[key] = value
      return oldValue
    }

    return nil
  }
}
