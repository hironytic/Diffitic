//
// DiffiticTests.swift
// DiffiticTests
//
// Copyright (c) 2017 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import XCTest
@testable import Diffitic

class DiffiticTests: XCTestCase {
    func testDiff() {
        //           01234567890123456
        let left =  "abdefggghiJKlmnop"
        let right = "abcdefghijklmnop"
        
        let result = diff(leftCount: left.characters.count, rightCount: right.characters.count) { (leftIndex, rightIndex) in
            return left[left.index(left.startIndex, offsetBy: leftIndex)] == right[right.index(right.startIndex, offsetBy: rightIndex)]
        }
        
        XCTAssertEqual(result.count, 7)
        
        let (type0, leftIndex0, leftCount0, rightIndex0, rightCount0) = result[0]
        XCTAssertEqual(type0, .identical)
        XCTAssertEqual(leftIndex0, 0)
        XCTAssertEqual(leftCount0, 2)
        XCTAssertEqual(rightIndex0, 0)
        XCTAssertEqual(rightCount0, 2)

        let (type1, leftIndex1, leftCount1, rightIndex1, rightCount1) = result[1]
        XCTAssertEqual(type1, .inserted)
        XCTAssertEqual(leftIndex1, 2)
        XCTAssertEqual(leftCount1, 0)
        XCTAssertEqual(rightIndex1, 2)
        XCTAssertEqual(rightCount1, 1)

        let (type2, leftIndex2, leftCount2, rightIndex2, rightCount2) = result[2]
        XCTAssertEqual(type2, .identical)
        XCTAssertEqual(leftIndex2, 2)
        XCTAssertEqual(leftCount2, 4)
        XCTAssertEqual(rightIndex2, 3)
        XCTAssertEqual(rightCount2, 4)

        let (type3, leftIndex3, leftCount3, rightIndex3, rightCount3) = result[3]
        XCTAssertEqual(type3, .deleted)
        XCTAssertEqual(leftIndex3, 6)
        XCTAssertEqual(leftCount3, 2)
        XCTAssertEqual(rightIndex3, 7)
        XCTAssertEqual(rightCount3, 0)

        let (type4, leftIndex4, leftCount4, rightIndex4, rightCount4) = result[4]
        XCTAssertEqual(type4, .identical)
        XCTAssertEqual(leftIndex4, 8)
        XCTAssertEqual(leftCount4, 2)
        XCTAssertEqual(rightIndex4, 7)
        XCTAssertEqual(rightCount4, 2)

        let (type5, leftIndex5, leftCount5, rightIndex5, rightCount5) = result[5]
        XCTAssertEqual(type5, .replaced)
        XCTAssertEqual(leftIndex5, 10)
        XCTAssertEqual(leftCount5, 2)
        XCTAssertEqual(rightIndex5, 9)
        XCTAssertEqual(rightCount5, 2)

        let (type6, leftIndex6, leftCount6, rightIndex6, rightCount6) = result[6]
        XCTAssertEqual(type6, .identical)
        XCTAssertEqual(leftIndex6, 12)
        XCTAssertEqual(leftCount6, 5)
        XCTAssertEqual(rightIndex6, 11)
        XCTAssertEqual(rightCount6, 5)
    }
    
    func testDiff2() {
        let left = ["dog", "cat", "cow", "sparrow", "swift"]
        let right = ["horse", "dog", "cat", "cow", "koala", "swift"]
        
        let result = diff(leftCount: left.count, rightCount: right.count) { (leftIndex, rightIndex) in
            return left[leftIndex] == right[rightIndex]
        }
        
        var values: [String] = []
        for segment in result {
            switch segment {
            case let (.identical, leftIndex, leftCount, _, _):
                values.append(contentsOf: left[leftIndex ..< leftIndex + leftCount])
            case let (.inserted, _, _, rightIndex, rightCount):
                values.append(contentsOf: right[rightIndex ..< rightIndex + rightCount])
            case (.deleted, _, _, _, _):
                break
            case let (.replaced, _, _, rightIndex, rightCount):
                values.append(contentsOf: right[rightIndex ..< rightIndex + rightCount])
            }
        }
        XCTAssertEqual(values, right)
    }
    
    func testSameLengthSequences() {
        let left = [1, 2, 3, 4]
        let right = [1, 3, 4, 5]
        
        let result = diff(leftCount: left.count, rightCount: right.count) { (leftIndex, rightIndex) in
            return left[leftIndex] == right[rightIndex]
        }
        
        XCTAssertEqual(result.count, 4)
        
        let (type0, leftIndex0, leftCount0, rightIndex0, rightCount0) = result[0]
        XCTAssertEqual(type0, .identical)
        XCTAssertEqual(leftIndex0, 0)
        XCTAssertEqual(leftCount0, 1)
        XCTAssertEqual(rightIndex0, 0)
        XCTAssertEqual(rightCount0, 1)
        
        let (type1, leftIndex1, leftCount1, rightIndex1, rightCount1) = result[1]
        XCTAssertEqual(type1, .deleted)
        XCTAssertEqual(leftIndex1, 1)
        XCTAssertEqual(leftCount1, 1)
        XCTAssertEqual(rightIndex1, 1)
        XCTAssertEqual(rightCount1, 0)
        
        let (type2, leftIndex2, leftCount2, rightIndex2, rightCount2) = result[2]
        XCTAssertEqual(type2, .identical)
        XCTAssertEqual(leftIndex2, 2)
        XCTAssertEqual(leftCount2, 2)
        XCTAssertEqual(rightIndex2, 1)
        XCTAssertEqual(rightCount2, 2)
        
        let (type3, leftIndex3, leftCount3, rightIndex3, rightCount3) = result[3]
        XCTAssertEqual(type3, .inserted)
        XCTAssertEqual(leftIndex3, 4)
        XCTAssertEqual(leftCount3, 0)
        XCTAssertEqual(rightIndex3, 3)
        XCTAssertEqual(rightCount3, 1)
    }
}

#if os(Linux)
extension DiffiticTests {
    static var allTests : [(String, (DiffiticTests) -> () throws -> Void)] {
        return [
            ("testDiff", testDiff),
        ]
    }
}
#endif
