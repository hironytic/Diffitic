# Diffitic

[![CI Status](http://img.shields.io/travis/hironytic/Diffitic.svg?style=flat)](https://travis-ci.org/hironytic/Diffitic)
[![Version](https://img.shields.io/cocoapods/v/Diffitic.svg?style=flat)](http://cocoapods.org/pods/Diffitic)
[![License](https://img.shields.io/cocoapods/l/Diffitic.svg?style=flat)](http://cocoapods.org/pods/Diffitic)
[![Platform](https://img.shields.io/cocoapods/p/Diffitic.svg?style=flat)](http://cocoapods.org/pods/Diffitic)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Diffitic is a module for detecting differences between two sequences written in Swift.

## Usage

This module provides a function `diff`.

```swift
public func diff(leftCount: Int,
                 rightCount: Int,
                 equalityChecker: (Int, Int) -> Bool)
                              -> [(DiffType, Int, Int, Int, Int)]
```

It takes two integer parameters and a closure parameter.
Two integers indicate the length of the "left" and "right" sequences, respectively.
A closure takes two indices of the "left" and "right" sequence, and then it returns whether the two elements specified by indices is same or not.

The `diff` doesn't care what type of data the both sequences actually are.
Here is an example that sequences are arrays of strings.

```swift
import Foundation
import Diffitic

let left = ["dog", "cat", "cow", "sparrow", "swift"]
let right = ["horse", "dog", "cat", "cow", "koala", "swift"]

let result = diff(leftCount: left.count, rightCount: right.count) { (leftIndex, rightIndex) in
    return left[leftIndex] == right[rightIndex]
}
```

The return value of the `diff` function is an array of segments.

One segment is represented as a tuple of five values: `type`, `leftIndex`, `leftCount`, `rightIndex` and `rightCount`.
The `leftIndex` and the `leftCount` point to a part of the left sequence.
The same applies to the `rightIndex` and the `rightCount`.
The `type` represents a type of this segment.

| `type`       | Description                                    |
|--------------|------------------------------------------------|
| `.identical` | The both parts of the sequences are same.      |
| `.inserted`  | The right part is inserted.                    |
| `.deleted`   | The left part is deleted.                      |
| `.replaced`  | The left part is replaced with the right part. |

In this example, the `result` consists of these four segments:

- 0: `(.inserted, 0, 0, 0, 1)`
- 1: `(.identical, 0, 3, 1, 3)`
- 2: `(.replaced, 3, 1, 4, 1)`
- 3: `(.identical, 4, 1, 5, 1)`

which means,

- 0: 1 element from index 0 in the right sequence (that is `"horse"`) is inserted at index 0 in the left sequence.
- 1: 3 elements from index 0 in the left sequence (`"dog"`, `"cat"` and `"cow"`) and 3 elements from index 1 in the right sequence (also `"dog"`, `"cat"` and `"cow"`) are same.
- 2: 1 element from index 3 in the left sequence (`"sparrow"`) is replaced with 1 element from index 4 in the right sequence (`"koala"`).
- 3: 1 element from index 4 in the left sequence (`"swift"`) and 1 element from index 5 in the right sequence (`"swift"`) are same.


## Requirements

- Swift 3.0+
- iOS 8.0+
- macOS 10.9+
- watchOS 2.0+
- tvOS 9.0+


## Installation

### CocoaPods

Diffitic is available through [CocoaPods](http://cocoapods.org).
To install it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod "Diffitic"
```

### Carthage

Diffitic is available through [Carthage](https://github.com/Carthage/Carthage).
To install it, simply add the following line to your Cartfile:

```
github "hironytic/Diffitic"
```

### Swift Package Manager

Diffitic is available through [Swift Package Manager](https://swift.org/package-manager/).
To install it, add dependency to your `Package.swift` file like following:

```swift
import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        .Package(url: "https://github.com/hironytic/Diffitic.git", majorVersion: 1),
    ]
)
```


## Author

Hironori Ichimiya, hiron@hironytic.com

## License

Diffitic is available under the MIT license. See the LICENSE file for more info.
