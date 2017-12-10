//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

class MemoryBlocks {
    private var blocks: [Int]
    private var stateHistory: Dictionary<String, Int> = [:]

    init(state: [Int]) {
        blocks = state
        let log = blocks.map({ String($0) }).joined(separator: ",")
        stateHistory[log] = 1
    }

    // Returns whether the step has been seen before
    func rebalanceStep() -> Int {
        guard let winner: Int = blocks.max(),
            let startIndex: Int = blocks.index(of: winner) else {
            return -1
        }

        blocks[startIndex] = 0
        for i: Int in 0..<winner {
            let newIndex = (startIndex + i + 1) % blocks.count
            blocks[newIndex] = blocks[newIndex] + 1
        }

        let log = blocks.map({ String($0) }).joined(separator: ",")
        let occuranceCount = (stateHistory[log] ?? 0) + 1
        if (occuranceCount > 1) {
            print("\(log) : \(occuranceCount)\n")
        }
        stateHistory[log] = occuranceCount
        return occuranceCount
    }
}

// Another problem that takes TOO LONG to calculate in the playgrounds UI. Uncomment if you dare.
//let initialBlocks: [Int] = [14, 0, 15, 12, 11, 11, 3, 5, 1, 6, 8, 4, 9, 1, 8, 4]
let initialBlocks: [Int] = [0, 2, 7, 0]

// Answer to part 1

func findFirstLoop() -> Int {
    var count = 0

    let blocks = MemoryBlocks(state: initialBlocks)
    repeat {
        count += 1
        let occuranceCount = blocks.rebalanceStep()
        if (occuranceCount == 2) {
            return count
        }
    } while(true)
}

findFirstLoop()

// Answer to part 2

func findLoopSize() -> Int {
    var count = 0

    var firstOccuranceCount = -1

    let blocks = MemoryBlocks(state: initialBlocks)
    repeat {
        count += 1
        let occuranceCount = blocks.rebalanceStep()
        if (occuranceCount == 2 && firstOccuranceCount < 0) {
            firstOccuranceCount = count
        }
        else if (occuranceCount == 3) {
            break
        }
    } while(true)
    return count - firstOccuranceCount
}

findLoopSize()
