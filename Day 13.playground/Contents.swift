// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

class Firewall {
    let layers: [(Int, Int)] // Index -> Height

    convenience init(input: String) {
        let rows: [(Int, Int)] = input.split(separator: "\n").map { (substr) -> (Int, Int) in
            let parts = substr.split(separator: ":")
                .flatMap({ Int(String($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))) })
            return (parts[0], parts[1])
        }

        self.init(layers: rows)
    }

    init(layers: [(Int, Int)]) {
        self.layers = layers
    }

    func findSafeDelay() -> Int {
        var delay = 1000000 // Spoiler alert: experimented and it's over a million
        while (getsCaught(withDelay: delay)) {
            if (delay % 10000 == 0) {
                print("made it to \(delay)")
            }
            delay += 1
        }
        return delay
    }

    func getsCaught(withDelay delay: Int = 0) -> Bool {
        for (index, height) in layers {
            if (isCaughtAtLayer(index: index, height: height, startDelay: delay)) {
                return true
            }
        }

        return false
    }

    func isCaughtAtLayer(index: Int, height: Int, startDelay: Int = 0) -> Bool {
        return ((startDelay + index) % (2 * (height - 1))) == 0
    }

    func caughtSeverity(withDelay delay: Int = 0) -> Int {
        return layers.reduce(0, { (soFar, layerPair) -> Int in
            let index = layerPair.0
            let height = layerPair.1

            if (isCaughtAtLayer(index: index, height: height, startDelay: delay)) {
                return soFar + (index * height)
            }

            return soFar
        })
    }
}

// Build the data structure

let input = try String(contentsOf: Bundle.main.url(forResource: "input", withExtension: "txt")!,
                       encoding: String.Encoding.utf8).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

let wall = Firewall(input: input)

// Solution to part 1

let caughtCount = wall.caughtSeverity()
print("You're caught \(caughtCount) severity")

// Solution to part 2

// Very expensive to calculate - commented out for safety.
//let safeDelay = wall.findSafeDelay()
//print("You'll be safe with a wait of \(safeDelay)")

