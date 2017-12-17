// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

enum Step {
    static let stepRegex = try! NSRegularExpression.init(pattern: "^([sxp])([0-9a-p]+)(/([0-9a-p]+))?$",
                                                         options: [])
    
    case spin(Int)
    case exchange(Int, Int)
    case partner(String, String)
    
    static func parseStep(input: String) -> Step? {
        let matches = Step.stepRegex.matches(in: input,
                                             options: [],
                                             range: NSMakeRange(0, input.count))

        guard matches.count > 0,
            let match = matches.first,
            match.numberOfRanges >= 3 else {
            return nil
        }
        
        guard let keyRange = Range(match.range(at: 1), in: input),
            let firstKeyRange = Range(match.range(at: 2), in: input) else {
                return nil
        }
        
        let indicator = input[keyRange]
        let firstKey = String(input[firstKeyRange])
        
        if (indicator == "s") {
            guard let spinSize = Int(firstKey) else {
                return nil
            }
            
            return .spin(spinSize)
        }
        else {
            guard let secondRange = Range(match.range(at: 4), in: input) else {
                return nil
            }
            
            let secondKey = String(input[secondRange])
            
            if (indicator == "x") {
                guard let origin = Int(firstKey),
                    let destination = Int(secondKey) else {
                    return nil
                }
                
                return exchange(origin, destination)
            }
            else if (indicator == "p") {
                return partner(firstKey, secondKey)
            }
        }
        
        return .spin(3)
    }
}

class Dance {
    static let names = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]
    
    var dancers = names
    
    class func parseSteps(input: String) -> [Step] {
        return input.split(separator: ",").flatMap({ Step.parseStep(input: String($0)) })
    }
    
    func perform(steps: [Step]) {
        for step in steps {
            switch step {
            case .spin(let distance):
                let split = (dancers.count - distance) % dancers.count
                dancers = Array(dancers[split..<dancers.count]) + Array(dancers[0..<split])
                break
            case .exchange(let ind1, let ind2):
                self.swap(index1: ind1, index2: ind2)
                break
            case .partner(let partner1, let partner2):
                guard let ind1 = dancers.index(of: partner1),
                    let ind2 = dancers.index(of: partner2) else {
                    continue
                }
                self.swap(index1: ind1, index2: ind2)
            }
        }
    }
    
    private func swap(index1 ind1: Int, index2 ind2: Int) {
        let oldSpot1 = dancers[ind1]
        dancers[ind1] = dancers[ind2]
        dancers[ind2] = oldSpot1
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
                       encoding: String.Encoding.utf8).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
let steps = Dance.parseSteps(input: input)

// Solution to part 1
func part1() {
    let wall = Dance()
    wall.perform(steps: steps)
    print("The resulting order is:")
    print(wall.dancers.joined(separator: ""))
}
part1()

// Solution to part 2
func part2() {
    let loop = Dance()
    var memobook: [String : Int] = [:]

    memobook[loop.dancers.joined(separator: "")] = 0

    var i = 0
    while i < 100000 {
        loop.perform(steps: steps)
        i = i + 1
        if (memobook[loop.dancers.joined(separator: "")] != nil) {
            break
        } else {
            memobook[loop.dancers.joined(separator: "")] = i
        }
    }
    // The point where the steady state first appeared
    let loopOffset = memobook[loop.dancers.joined(separator: "")] ?? 0
    let loopSize = i - loopOffset
    let loopValue = loop.dancers.joined(separator: "")

    let billion = 1000000000
    let distanceRemaining = (billion - loopOffset) % loopSize

    print("Discovered a loop of size \(loopSize) starting at offset \(loopOffset)")
    print("Results in order \(loopValue)")
    print("Leaves \(distanceRemaining) iterations to reach a billion.")
    for i in (0..<distanceRemaining) {
        if (i % 5 == 0) {
            print("Running iteration \(i)")
        }
        loop.perform(steps: steps)
    }

    print("The resulting order is:")
    print(loop.dancers.joined(separator: ""))
}
part2()
