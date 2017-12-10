//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

class ProgramPerson {
    let name: String
    let weight: Int

    let childrenNames: [String]

    var weightWithChildren: Int!

    var holding: [ProgramPerson] = []

    init(name nameIn: String, weight weightIn: Int, children: [String]) {
        name = nameIn
        weight = weightIn
        childrenNames = children
    }

    func calculateWeightWithChildren() -> Int {
        if let precalculated = self.weightWithChildren {
            return precalculated
        }

        if self.holding.isEmpty {
            self.weightWithChildren = self.weight
        } else {
            self.weightWithChildren = self.weight + self.holding.map({ $0.calculateWeightWithChildren() }).reduce(0, +)
        }

        return self.weightWithChildren
    }
}

struct TowerBuilder {
    static let personRegex = try! NSRegularExpression.init(pattern: "([a-z]+) \\(([0-9]+)\\)( -> ([a-z, ]+))?",
                                                           options: [])

    static func buildTower(input: [String]) -> ProgramPerson? {
        var rootPeople: [String : ProgramPerson] = [:]

        for description in input {
            let matches = TowerBuilder.personRegex.matches(in: description,
                                                           options: [],
                                                           range: NSMakeRange(0, description.count))
            guard matches.count > 0,
                let match = matches.first,
                match.numberOfRanges == 5 else {
                    continue
            }

            guard let nameRange = Range(match.range(at: 1), in: description),
                let weightRange = Range(match.range(at: 2), in: description) else {
                    continue
            }

            var childrenNames: [String] = []
            if let childrenRange = (match.range(at: 4).location != NSNotFound) ? Range(match.range(at: 4), in: description) : nil {
                childrenNames = description
                    .substring(with: childrenRange)
                    .split(separator: ",")
                    .map({ String($0).trimmingCharacters(in: CharacterSet.whitespaces) })
            }

            let person = ProgramPerson(name: String(description.substring(with: nameRange)),
                                       weight: Int(description.substring(with: weightRange)) ?? 0,
                                       children: childrenNames)

            rootPeople[person.name] = person
        }

        var orphans = Set(rootPeople.keys)

        for person in rootPeople.values {
            for childName in person.childrenNames {
                guard let child = rootPeople[childName] else {
                    print("Referenced child not found: \(childName)")
                    return nil
                }

                person.holding.append(child)
                orphans.remove(childName)
            }
        }

        guard orphans.count == 1, let rootName = orphans.first else {
            print("Wound up with more than one root!")
            return nil
        }

        return rootPeople[rootName]
    }

    static func findMisweight(_ rootIn: ProgramPerson) -> (ProgramPerson, ProgramPerson?) {
        rootIn.calculateWeightWithChildren()

        var wrongWeightParent: ProgramPerson? = nil
        var wrongWeightCandidate: ProgramPerson = rootIn

        while (true) {
            if (wrongWeightCandidate.holding.count > 1) {
                var weightInstances: [Int: Int] = [:]
                for child in wrongWeightCandidate.holding {
                    let instanceCount = (weightInstances[child.weightWithChildren] ?? 0) + 1
                    weightInstances[child.weightWithChildren] = instanceCount
                }

                if weightInstances.keys.count == 1 {
                    break;
                }

                for key in weightInstances.keys {
                    if (weightInstances[key] == 1) {
                        wrongWeightParent = wrongWeightCandidate
                        wrongWeightCandidate = wrongWeightParent!.holding.first(where: {
                            $0.weightWithChildren == key
                        })!
                    }
                }
            }
            else if (wrongWeightCandidate.holding.count == 1) {
                wrongWeightParent = wrongWeightCandidate
                wrongWeightCandidate = wrongWeightParent!.holding.first!
            }
            else {
                break;
            }
        }

        return (wrongWeightCandidate, wrongWeightParent)
    }
}

// Answer to part 1
let rows = try String(contentsOf: Bundle.main.url(forResource: "input", withExtension: "txt")!,
                      encoding: String.Encoding.utf8)
    .split(separator: "\n").map({String($0)})

let root = TowerBuilder.buildTower(input: rows)
root?.name

// Answer to part 2
let (misweigh, parent) = TowerBuilder.findMisweight(root!)
misweigh.weight
let misweightWithChildren = misweigh.weightWithChildren ?? 0
let siblingWeight = (parent!.holding.first(where: { $0.weightWithChildren != misweightWithChildren })?.weightWithChildren) ?? 0
siblingWeight
let properWeight = (siblingWeight - misweightWithChildren) + misweigh.weight
print("\(misweigh.name) weighs \(misweigh.weight) but should weigh \(properWeight)")
