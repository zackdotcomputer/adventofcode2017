//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

enum TestOperation {
    case lessThan
    case greaterThan
    case lessThanOrEqual
    case greaterThanOrEqual
    case equal
    case notEqual

    static func fromString(_ str: String) -> TestOperation? {
        switch str {
        case "<":
            return .lessThan
        case ">":
            return .greaterThan
        case "<=":
            return .lessThanOrEqual
        case ">=":
            return .greaterThanOrEqual
        case "==":
            return .equal
        case "!=":
            return .notEqual
        default:
            return nil
        }
    }
}

enum ActionOperation {
    case increment
    case decrement

    static func fromString(_ str: String) -> ActionOperation? {
        switch str {
        case "inc":
            return .increment
        case "dec":
            return .decrement
        default:
            return nil
        }
    }
}

struct RegisterOperation {
    let action: ActionOperation
    let handle: String
    let amount: Int
}

struct RegisterTest {
    let action: TestOperation
    let handle: String
    let amount: Int
}

class Registers {
    var registerRegister: [String : Int] = [:]
    var highWaterMark = 0

    func getRegister(_ handle: String) -> Int {
        if let value = registerRegister[handle] {
            return value
        } else {
            registerRegister[handle] = 0
            return 0
        }
    }

    func handle(_ instruction: RegisterInstruction) -> Void {
        if (test(test: instruction.test)) {
            perform(operation: instruction.action)
        }
    }

    func perform(operation: RegisterOperation) -> Void {
        let newValue: Int = self.getRegister(operation.handle) + ((operation.action == .increment ? 1 : -1) * operation.amount)

        registerRegister[operation.handle] = newValue

        if (newValue > self.highWaterMark) {
            self.highWaterMark = newValue
        }
    }

    func test(test: RegisterTest) -> Bool {
        let value = self.getRegister(test.handle)

        switch test.action {
        case .lessThan:
            return value < test.amount
        case .greaterThan:
            return value > test.amount
        case .lessThanOrEqual:
            return value <= test.amount
        case .greaterThanOrEqual:
            return value >= test.amount
        case .equal:
            return value == test.amount
        case .notEqual:
            return value != test.amount
        }
    }
}

class RegisterInstruction {
    // Expected structure of: b inc 5 if a > 1
    init?(_ tokens: [String]) {
        guard (tokens.count == 7),
        let testAction = TestOperation.fromString(tokens[5]),
        let movementAction = ActionOperation.fromString(tokens[1]),
        let movementAmount = Int(tokens[2]),
        let testAmount = Int(tokens[6]) else {
            return nil
        }

        action = RegisterOperation(action: movementAction, handle: tokens[0], amount: movementAmount)
        test = RegisterTest(action: testAction, handle: tokens[4], amount: testAmount)

    }

    let action: RegisterOperation
    let test: RegisterTest
}

extension String {
    func cellTokenize() -> [[String]] {
        return self.split(separator: "\n").flatMap({ (substr) -> [String]? in
            guard substr.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 else {
                return nil
            }

            return substr.split(separator: " ").map({ String($0) })
        })
    }
}

let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

let registry = Registers()
let instructions = input.cellTokenize().flatMap({ RegisterInstruction($0) })
instructions.forEach({ registry.handle($0) })

// Answer to part 1
registry.registerRegister.values.max()

// Answer to part 2
registry.highWaterMark
