// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

infix operator +-+: AdditionPrecedence
infix operator +|+: AdditionPrecedence

class Grid: Hashable {
    var contents: [[Bool]]

    var textRepresentation: String {
        return contents.map({ (row) -> String in
            return row.map({ $0 ? "#" : "." }).joined()
        }).joined(separator: "/")
    }

    public var hashValue: Int {
        return textRepresentation.hashValue
    }

    public static func ==(lhs: Grid, rhs: Grid) -> Bool {
        guard lhs.contents.count == rhs.contents.count else {
            return false
        }

        for i in 0..<lhs.contents.count {
            if (lhs.contents[i] != rhs.contents[i]) {
                return false
            }
        }

        return true
    }

    init(contents: [[Bool]]) {
        self.contents = contents
    }

    convenience init(condensed: String) {
        let rows = condensed.split(separator: "/")
        self.init(contents: rows.flatMap({ (row) -> [Bool]? in
            guard row.count > 0 else {
                return nil
            }

            return row.map({ $0 == "#" })
        }))
    }

    static func +-+ (left: Grid, right: Grid) -> Grid {
        guard (left.contents.count == right.contents.count) else {
            assertionFailure("Grids must be same size")
            return left
        }

        let newContents: [[Bool]] = (0..<left.contents.count).map({ (i) -> [Bool] in
            left.contents[i] + right.contents[i]
        })
        return Grid(contents: newContents)
    }

    static func +|+ (left: Grid, right: Grid) -> Grid {
        guard (left.contents.first?.count == right.contents.first?.count) else {
            assertionFailure("Grids must be same size")
            return left
        }

        return Grid(contents: left.contents + right.contents)
    }

    func split() -> [[Grid]] {
        guard contents.count == contents.first?.count else {
            assertionFailure("Can only decompose a square grid")
            return [[self]]
        }

        let gridDimension = (contents.count % 2 == 0) ? 2 : 3
        guard contents.count % gridDimension == 0 else {
            assertionFailure("Grid won't decompose evenly")
            return [[self]]
        }

        let chunks = contents.count / gridDimension
        return (0..<chunks).map({ (row) -> [Grid] in
            (0..<chunks).map({ (col) -> Grid in
                let rowRange = (row * gridDimension)..<((row + 1) * gridDimension)
                let colRange = (col * gridDimension)..<((col + 1) * gridDimension)
                let chunkContents = (rowRange).map({ (row) -> [Bool] in
                    return Array(contents[row][colRange])
                })
                return Grid(contents: chunkContents)
            })
        })
    }

    func allPermutations() -> [Grid] {
        return (0...3).flatMap({ (rotations) -> [Grid] in
            let rotated = self.rotate(times: rotations)
            return [rotated, rotated.flip(horizontally: true), rotated.flip(horizontally: false)]
        })
    }

    func flip(horizontally: Bool) -> Grid {
        return horizontally ? Grid(contents: self.contents.map({ $0.reversed() })) : Grid(contents: self.contents.reversed())
    }

    func rotate(times: Int) -> Grid {
        guard (0...3).contains(times) else {
            assertionFailure("Invalid number of rotations - must be 0 to 3")
            return self
        }

        func onceRotated() -> [[Bool]] {
            let colRange = (0..<(contents.first?.count ?? 0)).reversed()
            let rowRange = (0..<contents.count).reversed()
            return (colRange).map({ (column) -> [Bool] in
                return (rowRange).map({ (row) -> Bool in
                    return contents[row][column]
                })
            })
        }

        switch times {
        case 1:
            return Grid(contents: onceRotated())
        case 2:
            return Grid(contents: contents.reversed().map({ $0.reversed() }))
        case 3:
            return Grid(contents: onceRotated().reversed().map({ $0.reversed() }))
        default:
            return Grid(contents: contents)
        }
    }
}

class Painter {
    let rules: [Grid : Grid]

    var grid = Grid(condensed: ".#./..#/###")

    init(rulebook: [String]) {
        var mutableRules: [Grid : Grid] = [:]
        let rawRules = rulebook.flatMap { (rawRule) -> (Grid, Grid)? in
            guard let separatorRange = rawRule.range(of: " => ") else {
                assertionFailure("Invalid rule: \(rawRule)")
                return nil
            }

            let left = rawRule[rawRule.startIndex..<separatorRange.lowerBound]
            let right = rawRule[separatorRange.upperBound..<rawRule.endIndex]

            return (Grid(condensed: String(left)), Grid(condensed: String(right)))
        }

        for rule in rawRules {
            for permutation in rule.0.allPermutations() {
                mutableRules[permutation] = rule.1
            }
        }

        rules = mutableRules
    }

    func paint() -> Grid {
        let decomposed = grid.split()
        let expanded = decomposed.map { (row) -> [Grid] in
            return row.map({ (grid) -> Grid in
                guard let newGrid = rules[grid] else {
                    assertionFailure("Failed to find rule matching \(grid.textRepresentation)")
                    return grid
                }
                return newGrid
            })
        }
        let joined = expanded.flatMap({ (row) -> Grid? in
            return row.reduce(nil, { (soFarOpt, next) -> Grid? in
                guard let soFar = soFarOpt else {
                    return next
                }
                return soFar +-+ next
            })!
        }).reduce(nil, { (soFarOpt, next) -> Grid? in
            guard let soFar = soFarOpt else {
                return next
            }
            return soFar +|+ next
        })!
        grid = joined
        return joined
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
    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    .split(separator: "\n")
    .map({ String($0) })

// Solution to part 1

func part1() {
    let painter = Painter(rulebook: input)

    var result = painter.grid
    for _ in 0..<5 {
        result = painter.paint()
    }

    let onCount = result.textRepresentation.reduce(0) { (soFar, ch) -> Int in
        return soFar + (ch == "#" ? 1 : 0)
    }

    print("After 5 iterations, we had \(onCount) lights on")
}
//part1()

// Solution to part 2

func part2() {
    let painter = Painter(rulebook: input)

    var result = painter.grid
    for _ in 0..<18 {
        result = painter.paint()
    }

    let onCount = result.textRepresentation.reduce(0) { (soFar, ch) -> Int in
        return soFar + (ch == "#" ? 1 : 0)
    }

    print("After 5 iterations, we had \(onCount) lights on")
}

part2()

