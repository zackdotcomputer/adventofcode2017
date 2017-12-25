// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

infix operator +-+: AdditionPrecedence
infix operator +|+: AdditionPrecedence

class Grid: Hashable {
    var contents: [[Infection]]

    var textRepresentation: String {
        return contents.map({ (row) -> String in
            return row.map({ $0.rawValue }).joined()
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

    init(contents: [[Infection]]) {
        self.contents = contents
    }

    convenience init(size: Int) {
        self.init(contents: Array.init(repeating: Array.init(repeating: .clean, count: size), count: size))
    }

    convenience init(condensed: String) {
        self.init(inputRows: condensed.split(separator: "/").map({ String($0) }))
    }

    convenience init(inputRows: [String]) {
        self.init(contents: inputRows.flatMap({ (row) -> [Infection]? in
            guard row.count > 0 else {
                return nil
            }

            return row.map({ $0 == "#" ? .infected : .clean })
        }))
    }

    static func +-+ (left: Grid, right: Grid) -> Grid {
        guard (left.contents.count == right.contents.count) else {
            assertionFailure("Grids must be same size")
            return left
        }

        let newContents = (0..<left.contents.count).map({ (i) -> [Infection] in
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

        func onceRotated() -> [[Infection]] {
            let colRange = (0..<(contents.first?.count ?? 0)).reversed()
            let rowRange = (0..<contents.count).reversed()
            return (colRange).map({ (column) -> [Infection] in
                return (rowRange).map({ (row) -> Infection in
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

enum Infection: String {
    case clean = ".",
        weakened = "W",
        infected = "#",
        flagged = "F"
}

enum Heading {
    case up, down, left, right

    func turnLeft() -> Heading {
        switch self {
        case .up:
            return .left
        case .down:
            return .right
        case .left:
            return .down
        case .right:
            return .up
        }
    }

    func turnRight() -> Heading {
        switch self {
        case .up:
            return .right
        case .down:
            return .left
        case .left:
            return .up
        case .right:
            return .down
        }
    }

    func opposite() -> Heading {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}

class Infector {
    var x: Int
    var y: Int
    var direction: Heading

    var grid: Grid

    var infectedCount: Int = 0
    var cleanedCount: Int = 0

    init(grid: Grid) {
        x = grid.contents.count / 2
        y = grid.contents.count / 2
        direction = .up

        self.grid = grid
    }

    func step(evolved: Bool = false) {
        if (!evolved) {
            // If the current node is infected, it turns to its right. Otherwise, it turns to its left. (Turning is done in-place; the current node does not change.)
            // If the current node is clean, it becomes infected. Otherwise, it becomes cleaned. (This is done after the node is considered for the purposes of changing direction.)
            // The virus carrier moves forward one node in the direction it is facing.
            if (grid.contents[x][y] == .infected) {
                direction = direction.turnRight()
                grid.contents[x][y] = .clean
                cleanedCount += 1
            } else if (grid.contents[x][y] == .clean) {
                direction = direction.turnLeft()
                grid.contents[x][y] = .infected
                infectedCount += 1
            }
        } else {
//            Decide which way to turn based on the current node:
//            If it is clean, it turns left.
//            If it is weakened, it does not turn, and will continue moving in the same direction.
//            If it is infected, it turns right.
//            If it is flagged, it reverses direction, and will go back the way it came.
//            Modify the state of the current node:
//            Clean nodes become weakened.
//            Weakened nodes become infected.
//            Infected nodes become flagged.
//            Flagged nodes become clean.
//            The virus carrier moves forward one node in the direction it is facing.
            switch grid.contents[x][y] {
            case .clean:
                direction = direction.turnLeft()
                grid.contents[x][y] = .weakened
                break
            case .weakened:
                grid.contents[x][y] = .infected
                infectedCount += 1
                break
            case .infected:
                direction = direction.turnRight()
                grid.contents[x][y] = .flagged
                break
            case .flagged:
                direction = direction.opposite()
                grid.contents[x][y] = .clean
                cleanedCount += 1
                break
            }
        }

        switch direction {
        case .up:
            x -= 1
            break
        case .down:
            x += 1
            break
        case .left:
            y -= 1
            break
        case .right:
            y += 1
            break
        }

        let safeRange = 0..<grid.contents.count
        if (!safeRange.contains(x) || !safeRange.contains(y)) {
            expandGrid()
        }
    }

    func expandGrid() {
        let startingSize = grid.contents.count
        print("Expanding grid from \(startingSize)")
        let newGrid = Grid(size: startingSize * 3)
        for row in 0..<startingSize {
            for col in 0..<startingSize {
                newGrid.contents[startingSize + row][startingSize + col] = grid.contents[row][col]
            }
        }

        x += startingSize
        y += startingSize

        grid = newGrid
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
    let virus = Infector(grid: Grid(inputRows: input))
    for _ in 0..<10000 {
        virus.step()
    }

    print("The virus caused \(virus.infectedCount) infections")
}
//part1()

// Solution to part 2

func part2() {
    let virus = Infector(grid: Grid(inputRows: input))
    let target = 10000000
    for i in 0..<target {
        if (i % 10000 == 0) {
            print("Made it to step \(i) of \(target)")
        }
        virus.step(evolved: true)
    }

    print("The virus caused \(virus.infectedCount) infections")
}

part2()

