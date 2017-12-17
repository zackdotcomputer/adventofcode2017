// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

struct Coord: Hashable {
    let row: Int
    let col: Int
    
    public static func ==(lhs: Coord, rhs: Coord) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
    
    public var hashValue: Int {
        get {
            return "\(row),\(col)".hashValue
        }
    }
    
    public var adjacent: [Coord] {
        get {
            let spread = -1...1
            return spread.flatMap({ (rVariant) -> [Coord] in
                spread.flatMap({ (cVariant) -> Coord? in
                    // Make sure at least one variant value is 0 but not both
                    guard (rVariant == 0 || cVariant == 0) &&
                        (rVariant != 0 || cVariant != 0) else {
                        return nil
                    }
                    
                    return Coord(row: row + rVariant, col: col + cVariant)
                })
            })
        }
    }
}

class Disk {
    static let squareSize: Int = 128
    
    // The bool represents whether the block is used
    var blocks: [[Bool]]

    init() {
        blocks = (0..<Disk.squareSize).map({ (_) -> [Bool] in
            return Array.init(repeating: false, count: Disk.squareSize)
        })
    }
    
    var usedBlocks: Int {
        get {
            return blocks.reduce(0, { (soFar, row) -> Int in
                return soFar + row.reduce(0, { (rowSoFar, column) -> Int in
                    rowSoFar + (column ? 1 : 0)
                })
            })
        }
    }
    
    func countGroups() -> Int {
        var uncounted: Set<Coord> = Set()
        
        // Build up the set
        for rowInd in 0..<blocks.count {
            for colInd in 0..<blocks[rowInd].count {
                if (blocks[rowInd][colInd]) {
                    uncounted.insert(Coord(row: rowInd, col: colInd))
                }
            }
        }
        
        // Tear down the set
        var groupCount = 0
        while !uncounted.isEmpty {
            groupCount += 1
            let seed = uncounted.popFirst()!
            var seedCandidates = Set(seed.adjacent)
            while !seedCandidates.isEmpty {
                guard let candidate = seedCandidates.popFirst(), uncounted.contains(candidate) else {
                    continue
                }

                uncounted.remove(candidate)
                seedCandidates = seedCandidates.union(candidate.adjacent)
            }
        }
        return groupCount
    }

    func configureByHash(hash: String) {
        for row in 0..<blocks.count {
            let hashValue = KnotHash.hash(value: "\(hash)-\(row)")
            let hashBinaries = hashValue.flatMap({ (char) -> String? in
                guard let num = Int(String(char), radix: 16) else {
                    return nil
                }
                let binary = String(num, radix: 2, uppercase: false)
                if (binary.count > 4) {
                    let startIndex = binary.index(binary.endIndex, offsetBy: -4)
                    return String(binary[startIndex..<binary.endIndex])
                } else {
                    return String(repeating: "0", count: 4 - binary.count) + binary
                }
            }).joined()
            
            guard hashBinaries.count == blocks[row].count else {
                assertionFailure("Didn't get the right binary count")
                return
            }
            
            for column in 0..<hashBinaries.count {
                let charIndex = hashBinaries.index(hashBinaries.startIndex, offsetBy: column)
                blocks[row][column] = (hashBinaries[charIndex...charIndex] == "1")
            }
        }
    }
}

// Build the data structure

let input = "amgozmfv"

// Solution to part 1

func part1() {
    let d = Disk()
    d.configureByHash(hash: input)
    
    let usedCount = d.usedBlocks
    
    print("\(usedCount) blocks were used")
}
//part1()

// Solution to part 2

func part2() {
    let d = Disk()
    d.configureByHash(hash: input)
    
    let groups = d.countGroups()
    
    print("\(groups) groups")
}
part2()
