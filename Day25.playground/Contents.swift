// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
// MERRY CHRISTMAS!

import Foundation

// The Data structure & algorithms

class TuringTape {
    var tape: [Int : Bool] = [:]

    subscript(index: Int) -> Bool {
        get {
            return tape[index] ?? false
        }
        set(newValue) {
            tape[index] = newValue
        }
    }

    var diagnosticChecksum: Int {
        return tape.values.filter({ $0 }).count
    }
}

enum TuringState {
    case a, b, c, d, e, f
}

class TuringMachine {
    var index = 0
    var state: TuringState = .a
    let tape = TuringTape()

    var currentValue: Bool {
        return tape[index]
    }

    func write(newValue: Bool) {
        tape[index] = newValue
    }

    func moveLeft() {
        index -= 1
    }

    func moveRight() {
        index += 1
    }
}

class TuringProgram {
    let machine = TuringMachine()

    // Loop a specified number of steps, then return a checksum
    func diangostics(steps: Int) -> Int {
        for i in 0..<steps {
            if (i % 1000 == 0) {
                print("Made it to step \(i) out of \(steps)")
            }
            self.step()
        }

        return self.machine.tape.diagnosticChecksum
    }

    func step() {
        switch machine.state {
        case .a:
            if (!machine.currentValue) {
                machine.write(newValue: true)
                machine.moveRight()
                machine.state = .b
            } else {
                machine.write(newValue: false)
                machine.moveRight()
                machine.state = .c
            }
            break
        case .b:
            if (!machine.currentValue) {
                machine.write(newValue: false)
                machine.moveLeft()
                machine.state = .a
            } else {
                machine.write(newValue: false)
                machine.moveRight()
                machine.state = .d
            }
            break
        case .c:
            if (!machine.currentValue) {
                machine.write(newValue: true)
                machine.moveRight()
                machine.state = .d
            } else {
                machine.write(newValue: true)
                machine.moveRight()
                machine.state = .a
            }
            break
        case .d:
            if (!machine.currentValue) {
                machine.write(newValue: true)
                machine.moveLeft()
                machine.state = .e
            } else {
                machine.write(newValue: false)
                machine.moveLeft()
                machine.state = .d
            }
            break
        case .e:
            if (!machine.currentValue) {
                machine.write(newValue: true)
                machine.moveRight()
                machine.state = .f
            } else {
                machine.write(newValue: true)
                machine.moveLeft()
                machine.state = .b
            }
            break
        case .f:
            if (!machine.currentValue) {
                machine.write(newValue: true)
                machine.moveRight()
                machine.state = .a
            } else {
                machine.write(newValue: true)
                machine.moveRight()
                machine.state = .e
            }
            break
        }
    }
}

// Solution to part 1

func part1() {
    let alan = TuringProgram()
    let checksum = alan.diangostics(steps: 12399302)
    print("My checksum was: \(checksum)")
}
part1()

// Solution to part 2

func part2() {
    // There wasn't a part 2
    // Merry Christmas
}
//part2()

