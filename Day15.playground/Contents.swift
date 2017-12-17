// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

class Generator {
    var currentValue: Int
    let multFactor: Int
    let pickyFactor: Int
    static let remainderConstant: Int = 2147483647
    
    init(startingValue: Int, progressFactor: Int, pickyFactor pfin: Int = 1) {
        currentValue = startingValue
        multFactor = progressFactor
        pickyFactor = pfin
    }
    
    func next() -> Int {
        repeat {
            currentValue = (currentValue * multFactor) % Generator.remainderConstant
        } while (currentValue % pickyFactor != 0)
        return currentValue
    }
}

extension String {
    func take(last: Int) -> Substring {
        return self[self.index(self.endIndex, offsetBy: -1 * last)..<self.endIndex]
    }
}

extension Int {
    func last16Equals(_ rhs: Int) -> Bool {
        return (self & 0xFFFF) == (rhs & 0xFFFF)
    }
}

// Build the data structure

let inputA = 512
let inputB = 191

let factorA = 16807
let factorB = 48271

// Solution to part 1

func part1() {
    let genA = Generator(startingValue: inputA, progressFactor: factorA)
    let genB = Generator(startingValue: inputB, progressFactor: factorB)
    let fortymil: Int = 40000000
    var matchCount = 0
    for i in 0..<fortymil {
        if (i > 0 && i % 100000 == 0) {
            print("Made it to \(i)")
        }

        let left = genA.next()
        let right = genB.next()

        if (left.last16Equals(right)) {
            matchCount += 1
        }
    }
    
    print("There were \(matchCount) matches")
}
//part1()

// Solution to part 2

func part2() {
    let genA = Generator(startingValue: inputA, progressFactor: factorA, pickyFactor: 4)
    let genB = Generator(startingValue: inputB, progressFactor: factorB, pickyFactor: 8)
    let fivemil: Int = 5000000
    var matchCount = 0
    for i in 0..<fivemil {
        if (i > 0 && i % 100000 == 0) {
            print("Made it to \(i)")
        }

        let left = genA.next()
        let right = genB.next()

        if (left.last16Equals(right)) {
            matchCount += 1
        }
    }

    print("There were \(matchCount) matches")
}
part2()

