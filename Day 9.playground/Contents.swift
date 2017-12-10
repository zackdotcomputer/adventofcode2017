//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

class GoodGroup {
    var children: [GoodGroup] = []
    var parent: GoodGroup? {
        didSet {
            if let validParent = parent {
                validParent.children.append(self)
            }
        }
    }

    func score(atLevel level: Int = 1) -> Int {
        return level + children.reduce(0, { (soFar, next) -> Int in
            soFar + next.score(atLevel: level + 1)
        })
    }
}

func parse(input: String) -> GoodGroup? {
    var insideGarbage = false
    var invalidateBangInEffect = false
    var garbageCount = 0

    var currentGroup: GoodGroup? = nil
    var finishedRootGroups: [GoodGroup] = []

    for char in input {
        if (insideGarbage) {
            if (!invalidateBangInEffect) {
                if (char == ">") {
                    // Escape!
                    insideGarbage = false
                }
                else if (char == "!") {
                    invalidateBangInEffect = true
                }
                else {
                    garbageCount += 1
                }
            }
            else {
                // The invalidation has been done
                invalidateBangInEffect = false
            }
        }
        else if (char == "{") {
            // Open group
            let newGroup = GoodGroup()
            newGroup.parent = currentGroup
            currentGroup = newGroup
        }
        else if (char == "}") {
            // Close group
            if let current = currentGroup, current.parent == nil {
                finishedRootGroups.append(current)
            }
            currentGroup = currentGroup?.parent
        }
        else if (char == ",") {
            // Sibling - I guess this can be ignored?
        }
        else if (char == "<") {
            // Begin garbage
            insideGarbage = true
        }
        else if (char == "\n") {
            // Ignore Newlines
        }
        else {
            assertionFailure("Invalid character \(char)!")
            break
        }
    }

    // Answer to part 2
    print("processed! had \(garbageCount) bad characters")

    guard finishedRootGroups.count == 1 else {
        return nil
    }
    return finishedRootGroups.first
}

let content = try String(contentsOf: Bundle.main.url(forResource: "input", withExtension: "txt")!,
                         encoding: String.Encoding.utf8)

let results = parse(input: content)
// Answer to part 1
results?.score()

