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

    func run(instructions: [RegOperation],
             sendBlock: (Int) -> Void,
             receiveBlock: () -> (Int?, Bool)) {
        self.setup(instructions: instructions)
        while(self.hasNext()) {
            let _ = self.step(sendBlock: sendBlock, receiveBlock: receiveBlock)
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

    func step(sendBlock: (Int) -> Void,
              receiveBlock: () -> (Int?, Bool)) -> OperationResult? {
        if (hasNext()) {
            let res = perform(step: instructions[currentStep],
                              sendBlock: sendBlock,
                              receiveBlock: receiveBlock)
            if (res.wasPerformed) {
                switch res.originalInstruction {
                case .jgz(_, _):
                    currentStep += (res.resultValue ?? 1) - 1
                default:
                    break
                }
            }
            else { // Res not performed
                switch res.originalInstruction {
                case .rcv(_):
                    // If a receive call couldn't complete successfully, repeat this step until the other program catches up
                    currentStep -= 1
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

    private func perform(step: RegOperation,
                         sendBlock: (Int) -> Void,
                         receiveBlock: () -> (Int?, Bool)) -> OperationResult {
        switch step {
        case .snd(let reg):
            let freq = getRegister(reg)
            sendBlock(freq)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: freq,
                                   remoteKillSignal: false)
        case .rcv(let dest):
            let receivedTuple = receiveBlock()
            guard let received = receivedTuple.0 else {
                return OperationResult(originalInstruction: step,
                                       wasPerformed: false,
                                       resultValue: nil,
                                       remoteKillSignal: receivedTuple.1)
            }
            setRegister(dest, value: received)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: received,
                                   remoteKillSignal: receivedTuple.1)
        case .set(let reg, let val):
            let result = getRegister(val)
            setRegister(reg, value: result)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: result,
                                   remoteKillSignal: false)
        case .add(let reg, let val):
            let result = getRegister(reg) + getRegister(val)
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
        case .mod(let reg, let val):
            let result = getRegister(reg) % getRegister(val)
            setRegister(reg, value: result)
            return OperationResult(originalInstruction: step,
                                   wasPerformed: true,
                                   resultValue: result,
                                   remoteKillSignal: false)
        case .jgz(let check, let offsetRegister):
            let val = getRegister(check)
            let offset = getRegister(offsetRegister)
            let perform = (val > 0)
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
    case snd(String)
    case set(String, String)
    case add(String, String)
    case mul(String, String)
    case mod(String, String)
    case rcv(String)
    case jgz(String, String)

    static func fromString(_ str: [String]) -> RegOperation? {
        // All ops take an argument at least
        guard str.count > 1 else {
            return nil
        }

        // Handle single argument cases first
        switch str[0] {
        case "snd":
            return snd(str[1])
        case "rcv":
            return rcv(str[1])
        default:
            break // Swift book says this is ok for switches?
        }

        guard str.count == 3 else {
            return nil
        }

        switch str[0] {
        case "set":
            return set(str[1], str[2])
        case "add":
            return add(str[1], str[2])
        case "mul":
            return mul(str[1], str[2])
        case "mod":
            return mod(str[1], str[2])
        case "jgz":
            return jgz(str[1], str[2])
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

let testInput = """
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d
"""

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
    var lastSentValue = 0

    reggie.run(instructions: instructions, sendBlock: { (sent) in
        lastSentValue = sent
    }) { () -> (Int?, Bool) in
        print("First time rcv was ran, the value was \(lastSentValue)")
        return (nil, true)
    }
}
//part1()

// Solution to part 2

func part2() {
    let instructions = RegOperation.parseInput(input)

    let reggie = Registers(id: 0)
    var reggieQueue: [Int] = []
    var reggieDead: Bool = false

    var wattsSendCount: Int = 0

    let watts = Registers(id: 1)
    var wattsQueue: [Int] = []
    var wattsDead: Bool = false

    print("Running instructions...")

    reggie.setup(instructions: instructions)
    watts.setup(instructions: instructions)

    while (reggie.hasNext() || watts.hasNext()) {
        reggie.step(sendBlock: {
            reggieQueue.insert($0, at: 0)
        }, receiveBlock: { () -> (Int?, Bool) in
            if let next = wattsQueue.popLast() {
                return (next, false)
            }

            reggieDead = true
            return (nil, (wattsDead || !watts.hasNext()))
        })

        watts.step(sendBlock: {
            wattsQueue.insert($0, at: 0)
            wattsSendCount += 1
        }, receiveBlock: { () -> (Int?, Bool) in
            if let next = reggieQueue.popLast() {
                return (next, false)
            }

            wattsDead = true
            return (nil, (reggieDead || !reggie.hasNext()))
        })
    }
    print("Watts sent \(wattsSendCount) messages")
}
//part2()

