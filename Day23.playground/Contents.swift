// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

class Registers {
    var registerRegister: [String : Int] = [:]
    var currentStep = 0
    var instructions: [RegOperation] = []

    let programId: Int

    init(id: Int) {
        programId = id
    }

    private func getRegister(_ handle: String) -> Int {
        if let rawValue = Int(handle) {
            return rawValue
        }
        if let value = registerRegister[handle] {
            return value
        } else {
            registerRegister[handle] = 0
            return 0
        }
    }

    private func setRegister(_ handle: String, value: Int) {
        registerRegister[handle] = value
    }

    func run(instructions: [RegOperation]) {
        self.setup(instructions: instructions)
        while(self.hasNext()) {
            let _ = self.step()
        }
    }

    func setup(instructions: [RegOperation]) {
        registerRegister = ["p": self.programId]
        self.instructions = instructions
        currentStep = 0
    }

    func hasNext() -> Bool {
        return currentStep < instructions.count
    }

    func step() -> OperationResult? {
        if (hasNext()) {
            let res = perform(step: instructions[currentStep])
            if (res.wasPerformed) {
                switch res.originalInstruction {
                case .jnz(_, _):
                    currentStep += (res.resultValue ?? 1) - 1
                default:
                    break
                }
            }

            currentStep += 1

            if (res.remoteKillSignal) {
                currentStep = instructions.count
            }

            return res
        }

        return nil
    }

    private func perform(step: RegOperation) -> OperationResult {
        switch step {
        case .set(let reg, let val):
            let result = getRegister(val)
            setRegister(reg, value: result)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: result,
                                   remoteKillSignal: false)
        case .sub(let reg, let val):
            let result = getRegister(reg) - getRegister(val)
            setRegister(reg, value: result)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: result,
                                   remoteKillSignal: false)
        case .mul(let reg, let val):
            let result = getRegister(reg) * getRegister(val)
            setRegister(reg, value: result)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: result,
                                   remoteKillSignal: false)
        case .jnz(let check, let offsetRegister):
            let val = getRegister(check)
            let offset = getRegister(offsetRegister)
            let perform = (val != 0)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: perform,
                                   resultValue: offset,
                                   remoteKillSignal: false)
        }
    }
}

struct OperationResult {
    let originalInstruction: RegOperation
    let wasPerformed: Bool
    let resultValue: Int?
    let remoteKillSignal: Bool
}

enum RegOperation {
    case set(String, String)
    case sub(String, String)
    case mul(String, String)
    case jnz(String, String)

    static func fromString(_ str: [String]) -> RegOperation? {
        // All ops take an argument at least
        guard str.count == 3 else {
            return nil
        }

        switch str[0] {
        case "set":
            return set(str[1], str[2])
        case "sub":
            return sub(str[1], str[2])
        case "mul":
            return mul(str[1], str[2])
        case "jnz":
            return jnz(str[1], str[2])
        default:
            return nil
        }
    }

    static func parseInput(_ input: String) -> [RegOperation] {
        return input.cellTokenize().flatMap({ self.fromString($0) })
    }
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

// Build the data structure

let textfileURL = { () -> URL? in
    if let localfile = Bundle.main.url(forResource: "input", withExtension: "txt") {
        return localfile
    } else {
        print("Please enter file path")
        guard let input = readLine() else {
            return nil
        }
        return URL.init(fileURLWithPath: input)
    }
}()

let input = try String(contentsOf: textfileURL!,
                       encoding: String.Encoding.utf8)

// Solution to part 1

func part1() {
    let instructions = RegOperation.parseInput(input)
    let reggie = Registers(id: 0)
    print("Running instructions...")
    var mulCallCount = 0

    reggie.setup(instructions: instructions)
    while(reggie.hasNext()) {
        let result = reggie.step()

        if let instruction = result?.originalInstruction {
            switch instruction {
            case .mul(_, _):
                mulCallCount += 1
                break
            default:
                break
            }
        }
    }
    print("Reggie ran mul \(mulCallCount) times")
}
//part1()

// Solution to part 2

func part2() {
    print("Running my condensed instructions...")

    var h = 0

    let starting = 108100
    for i in 0...1000 {
        let b = starting + (i * 17)
        let sqrtb = Int(sqrt(Double(b)))

        // Test whether b is prime (counting non-primes)
        if ((2..<sqrtb).contains(where: { b % $0 == 0 })) {
            h += 1
        }
    }

    print("Reggie's final H was \(h)")
}
//part2()
