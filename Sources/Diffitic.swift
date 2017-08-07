//
// Diffitic.swift
// Diffitic
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

// This module uses the algorithm described in:
// S Wu, U Manber, G Myers, W Miller: "An O(NP) Sequence Comparison Algorithm", Information Processing Letters (1990)


public enum DiffType {
    case identical
    case inserted
    case deleted
    case replaced
}

// Note that each x, y in FPData equals to
// index-of-shorter-sequence + 1, index-of-longer-sequence + 1.
private class FPData {
    let y: Int      // y-coordinate of the furthest point (corresponding to fp[k] in Wu's algorithm)
    let x: Int      // x-coordinate of the furthest point
    let prevFPData: FPData?    // FPData located before snake
    
    init(y: Int, x: Int, prevFPData: FPData?) {
        self.y = y
        self.x = x
        self.prevFPData = prevFPData
    }
}

// working storage for furthest point on diagonal k
// (corresponding to fp in Wu's algorithm except that the value is (index-of-fpDataVector + 1).
// if the value is 0, it meens "not computed" and is described as -1 in Wu's one.)
private class FurthestPoints {
    private let offset: Int
    private var buffer: [FPData?]
    
    public init(m: Int, n: Int) {
        offset = m + 1
        buffer = Array(repeating: nil, count: m + n + 3)
    }
    
    public subscript(index: Int) -> FPData? {
        get {
            return buffer[offset + index]
        }
        set {
            buffer[offset + index] = newValue
        }
    }
}

private class DiffCore {
    let isSwapped: Bool // true if left is longer, false if right is longer
    let m: Int  // length of shorter sequence
    let n: Int  // length of longer sequence
    let fp: FurthestPoints
    var lastFPData: FPData? = nil
    var result: [(DiffType, Int, Int, Int, Int)] = []
    
    init(leftCount: Int, rightCount: Int) {
        isSwapped = leftCount > rightCount
        m = (isSwapped) ? rightCount : leftCount
        n = (isSwapped) ? leftCount : rightCount
        fp = FurthestPoints(m: m, n: n)
    }
    
    // Detects differences.
    func detect(_ equalityChecker: (Int, Int) -> Bool) {
        // handle special case: shorter sequence is empty
        if m == 0 {
            if n != 0 {
                // the longer sequence is not empty
                if (isSwapped) {
                    outputResult(diffType: .deleted, from0: 0, count0: n, from1: 0, count1: 0)
                } else {
                    outputResult(diffType: .inserted, from0: 0, count0: 0, from1: 0, count1: n)
                }
            }
            return
        }
        
        // traverse
        let delta = n - m
        for p in 0 ..< m {
            for k in -p ... delta - 1 {
                snake(k, equalityChecker)
            }
            for k in (delta ... delta + p).reversed() {
                snake(k, equalityChecker)
            }
            
            if let fpDelta = fp[delta] {
                if fpDelta.y == n {
                    break
                }
            }
        }
        
        // trace the path and make a diff-result
        makeResult()
    }
    
    // The "snake".
    // It does not only traverse diagnonal edges, but remember its path.
    func snake(_ k: Int, _ equalityChecker: (Int, Int) -> Bool) {
        let fpData0 = fp[k - 1]
        let fpData1 = fp[k + 1]
  
        let fpY0 = fpData0?.y ?? -1
        let fpY1 = fpData1?.y ?? -1
        
        var y: Int
        let prevFPData: FPData?
        if fpY0 + 1 > fpY1 {
            y = fpY0 + 1
            prevFPData = fpData0
        } else {
            y = fpY1
            prevFPData = fpData1
        }
        var x = y - k
        
        while x < m && y < n && (isSwapped ? equalityChecker(y, x) : equalityChecker(x, y)) {
            x += 1
            y += 1
        }
        
        let data = FPData(y: y, x: x, prevFPData: prevFPData)
        lastFPData = data
        fp[k] = data
    }

    // Traces the path and makes a diff-result.
    func makeResult() {
        // First of all, let data be the lastFPData
        // It was found in the last snake, so it equals to the last furthest point.
        // Note that lastFPData is not nil since at least one snake is occurred.
        // The only one case that no snakes occurs is m == 0,
        // but it is handled as a special case in the top of detect(_:) and this function is not called.
        var data: FPData = lastFPData!
        var to0 = isSwapped ? data.y : data.x
        var to1 = isSwapped ? data.x : data.y
        var prevData = data.prevFPData
        while prevData != nil {
            data = prevData!
            prevData = data.prevFPData
            let from0 = isSwapped ? data.y : data.x
            let from1 = isSwapped ? data.x : data.y
            if from1 - from0 < to1 - to0 {
                // inserted
                if from1 + 1 < to1 {
                    // output the path of snake in advance
                    outputResult(diffType: .identical, from0: from0, count0: to1 - (from1 + 1), from1: from1 + 1, count1: to1 - (from1 + 1))
                }
                outputResult(diffType: .inserted, from0: from0, count0: 0, from1: from1, count1: 1)
            } else {
                // deleted
                if from0 + 1 < to0 {
                    // output the path of snake in advance
                    outputResult(diffType: .identical, from0: from0 + 1, count0: to0 - (from0 + 1), from1: from1, count1: to0 - (from0 + 1))
                }
                outputResult(diffType: .deleted, from0: from0, count0: 1, from1: from1, count1: 0)
            }
            
            to0 = from0
            to1 = from1
        }
        if to0 != 0 {
            // It reaches here when the first segment is "identical".
            // Because the first furthest point should be (0,0) if the first segment is "inserted" or "deleted",
            // then it should be to0 == to1 == 0 at the end of the loop.
            outputResult(diffType: .identical, from0: 0, count0: to0, from1: 0, count1: to0)
        }
    }
    
    // Outputs the result. Called in makeResult.
    func outputResult(diffType: DiffType, from0: Int, count0: Int, from1: Int, count1: Int) {
        // combine each consecutive "deleted"s or consequcive "inserted"s into one.
        // and if is is found that a consecutive "inserted"-("deleted" or "replaced") or a consecutive "deleted"-("inserted" or "replaced"),
        // then it comes into one "replaced"
        if let (lastType, lastFrom0, lastCount0, lastFrom1, lastCount1) = result.last {
            var toBind = false
            var type = lastType
            if lastFrom0 == from0 + count0 && lastFrom1 == from1 + count1 {
                if diffType == .inserted {
                    if lastType == .inserted || lastType == .replaced {
                        toBind = true
                    } else if lastType == .deleted {
                        type = .replaced
                        toBind = true
                    }
                } else if diffType == .deleted {
                    if lastType == .deleted || lastType == .replaced {
                        toBind = true
                    } else if lastType == .inserted {
                        type = .replaced
                        toBind = true
                    }
                }
            }
            if toBind {
                result[result.count - 1] = (type, from0, lastCount0 + count0, from1, lastCount1 + count1)
                return
            }
        }
        
        // not combined? then append it.
        result.append((diffType, from0, count0, from1, count1))
    }
}

/// Detect differences between two sequences.
/// - parameter leftCount: Number of elements in left sequence.
/// - parameter rightCount: Number of elements in right sequence.
/// - parameter equalityChecker: A function which takes two indices (for left and right), and returns whether the elements are same.
/// - parameter leftIndex: Index of left sequence.
/// - parameter rightIndex: Index of right sequence.
/// - returns: Array of edit segments.
public func diff(leftCount: Int, rightCount: Int, equalityChecker: (_ leftIndex: Int, _ rightIndex: Int) -> Bool) -> [(DiffType, Int, Int, Int, Int)] {
    let diffCore = DiffCore(leftCount: leftCount, rightCount: rightCount)
    diffCore.detect(equalityChecker)
    return diffCore.result.reversed()
}
