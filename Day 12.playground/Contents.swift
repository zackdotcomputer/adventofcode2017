// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

class Network {
    var graph: [Int : [Int]] = [:]

    func add(rawRow: String) {
        guard let divider: Range = rawRow.range(of: "<->") else {
            return
        }

        // Get the left as an int, and the right as a CSL of ints
        guard let left = Int(String(rawRow[rawRow.startIndex..<divider.lowerBound]).trimmingCharacters(in: CharacterSet.whitespaces)) else {
            return
        }
        let right = {() -> [Int] in
            let rightString = String(rawRow[divider.upperBound...]).split(separator: ",")
            return rightString.flatMap({ Int(String($0).trimmingCharacters(in: CharacterSet.whitespaces)) })
        }()

        // Add 'em to the network graph
        graph[left] = right
    }

    // Taking a starting player (second argument is for recusion memoization), returns the
    // set of other players reachable through the network from that starting player.
    func reachableFrom(starting: Int, knownSoFar: Set<Int>? = nil) -> Set<Int> {
        let baseResults = Set([starting]).union(knownSoFar ?? Set())

        // No children = network of 1
        guard let myChildren = graph[starting] else {
            return baseResults
        }

        // Using reduce, we build the memo table in soFar as we progress
        return myChildren.reduce(baseResults, { (soFar, child) -> Set<Int> in
            // Prevent repetitive exploration using the memo table!
            guard !soFar.contains(child) else {
                return soFar
            }

            return soFar.union(reachableFrom(starting: child, knownSoFar: soFar))
        })
    }

    // Walk the population, finding their closed networks until you have linked them all
    func identifyGroups() -> [Set<Int>] {
        var unvillagers: Set<Int> = Set(graph.keys)
        var knownGroups: [Set<Int>] = []

        while(!unvillagers.isEmpty) {
            guard let nextVillage = unvillagers.first else{
                assertionFailure("Can't pull villager from nonempty list?!")
                break
            }
            let nextGroup = reachableFrom(starting: nextVillage)
            unvillagers = unvillagers.subtracting(nextGroup)
            knownGroups.append(nextGroup)
        }

        return knownGroups
    }
}

// Build the network from the input

let input = try String(contentsOf: Bundle.main.url(forResource: "input", withExtension: "txt")!,
                       encoding: String.Encoding.utf8).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    .split(separator: "\n")

let net = Network()
input.forEach({ net.add(rawRow: String($0)) })

// Solution to part 1

let reachable = net.reachableFrom(starting: 0)
print("\(reachable.count) reachable")

// Solution to part 2

let groups = net.identifyGroups()
print("\(groups.count) subgroups")
