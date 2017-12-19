// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

class LineFollower {
    static let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    let charArr2d: [[String]]

    var steps = 0

    init(input: String) {
        charArr2d = input.split(separator: "\n").map({ (row: Substring) in row.map({ String($0) }) })
    }

    func countSteps() {
        steps = 0

        var startingY = 0

        guard let entryX = charArr2d[startingY].index(of: "|") else {
            return
        }
        var startingX = entryX
        var currentDirection = Direction.down

        while (true) {
            steps += 1
            // Take a step in the specified direction
            switch currentDirection {
            case .down:
                startingY += 1
                break
            case .up:
                startingY -= 1
                break
            case .left:
                startingX -= 1
                break
            case .right:
                startingX += 1
                break
            }

            guard (0 <= startingY && 0 <= startingX && startingY < charArr2d.count && startingX < charArr2d[startingY].count) else {
                assertionFailure("Wandered off the map at \(startingX), \(startingY)")
                return
            }

            let currentLetter = charArr2d[startingY][startingX]

            // If it's a corner, figure out where to go instead
            if (currentLetter == "+") {
                var validDirections: Set<Direction> = Set([.down, .up, .left, .right])
                validDirections.remove(currentDirection.opposite) // Can't backtrack
                validDirections = validDirections.filter({ (dir) -> Bool in
                    guard let thatDirection = go(direction: dir, fromX: startingX, fromY: startingY) else {
                        return false
                    }
                    return thatDirection != dir.counterSymbol
                })
                guard validDirections.count == 1, let newDirection = validDirections.first else {
                    assertionFailure("Couldn't find way from \(startingX), \(startingY), which is a \(charArr2d[startingY][startingX])")
                    return
                }

                currentDirection = newDirection
            }

            // If it's a letter, check if we're done
            if (LineFollower.letters.contains(currentLetter)) {
                print("hit \(currentLetter)")
                if (go(direction: currentDirection, fromX: startingX, fromY: startingY) == nil) {
                    steps += 1 // To land on the letter
                    break // We found an exit
                }
            }
        }
    }

    func go(direction: Direction, fromX: Int, fromY: Int) -> String? {
        var useX = fromX
        var useY = fromY

        switch direction {
        case .down:
            useY += 1
            break
        case .up:
            useY -= 1
            break
        case .left:
            useX -= 1
            break
        case .right:
            useX += 1
            break
        }

        guard (0 <= useY && 0 <= useX && useY < charArr2d.count && useX < charArr2d[useY].count) else {
            return nil
        }

        let result = charArr2d[useY][useX]

        if (result == " ") {
            return nil
        }

        return result
    }
}

enum Direction {
    case down, up, left, right

    var counterSymbol: String {
        switch self {
        case .down, .up:
            return "-"
        case .left, .right:
            return "|"
        }
    }

    var opposite: Direction {
        switch self {
        case .down:
            return .up
        case .up:
            return .down
        case .left:
            return .right
        case .right:
            return .left
        }
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

// Lol I did part 1 by hand. My solution for part 2 does solve it, though, but I don't think I'd have gotten top 300 for it...

// Solution to part 2

func part2() {
    let line = LineFollower(input: input)
    line.countSteps()
    print("The path takes \(line.steps) steps")
}
part2()

