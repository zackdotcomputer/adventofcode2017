// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

class CircularBuffer {
    var values: [Int] = [0]
    var currentPosition = 0

    func stepForwardAndInsert(steps: Int, value: Int) {
        currentPosition = (currentPosition + steps + 1) % values.count
        values.insert(value, at: currentPosition)
    }
}

class SpinLock {
    let stepSize: Int

    let buffer: CircularBuffer

    var step = 0

    init(onBuffer: CircularBuffer, stepSize: Int) {
        buffer = onBuffer
        self.stepSize = stepSize
    }

    func stepForward() {
        step += 1
        buffer.stepForwardAndInsert(steps: stepSize, value: step)
    }
}

// Build the data structure

let stepSizeInput = 314

// Solution to part 1

func part1() {
    let buffer = CircularBuffer()
    let lock = SpinLock(onBuffer: buffer, stepSize: stepSizeInput)

    for _ in 0..<2017 {
        lock.stepForward()
    }

    print("Our final buffer is:")
    print(buffer.values.map({ String($0) }).joined(separator: "\n"))
}
//part1()

// Solution to part 2

func part2() {
    var valueAfterZero = 0

    let fiftyMillion = 50000000

    var currentPosition = 0
    for i in 1...fiftyMillion {
        currentPosition = ((currentPosition + stepSizeInput) % (i)) + 1
        if currentPosition == 1 {
            valueAfterZero = i
        }
    }

    print("The value after 0 is: \(valueAfterZero)")
}
part2()

