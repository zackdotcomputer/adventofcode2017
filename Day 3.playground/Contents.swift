//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

let input: Int = 277678

class SpiralStorage {
    // Cheating - storing just as a direction of linear position -> value
    private var values: [Int: Int] = [:]

    // Setter and getter by linear position
    func set(value: Int, toPosition pos: Int) -> Void {
        guard (pos > 0) else {
            assertionFailure("Invalid position \(pos) - must be greater than 0")
            return
        }
        values[pos] = value
    }

    func get(atPosition pos: Int) -> Int? {
        return values[pos]
    }

    // Setter and getter by 2d coordinate (with position 1 at the origin and spiraling outward)
    func set(value: Int, toCoordinate coord: Coordinate) -> Void {
        self.set(value: value, toPosition: coord.position)
    }

    func get(atCoordinate coord: Coordinate) -> Int? {
        return self.get(atPosition: coord.position)
    }

    // A coordinate in the x/y space of the spiral (with position 1 as the origin)
    struct Coordinate {
        let x: Int
        let y: Int

        init(x xIn: Int, y yIn: Int) {
            x = xIn
            y = yIn
        }

        init?(position pos: Int) {
            guard (pos > 0) else {
                assertionFailure("Invalid position \(pos) - must be greater than 0")
                return nil
            }

            // Special case position 1 as the origin
            if (pos == 1) {
                self.init(x: 0, y: 0)
            }
            else {
                let r = Geometry.ring(forPosition: pos)
                let s = Side(position: pos) ?? .bottom
                let c = Geometry.maxValue(forRing: r) - Geometry.midpointOffset(side: s, ring: r) - pos

                switch s {
                case .bottom: self.init(x: -1 * c, y: -1 * r)
                case .left: self.init(x: -1 * r, y: c)
                case .top: self.init(x: c, y: r)
                case .right: self.init(x: r, y: -1 * c)
                }
            }
        }

        var adjacent: [Coordinate] {
            let variance = (-1...1)
            return variance.flatMap({ (yVariance) -> [Coordinate] in
                return variance.flatMap({ (xVariance) -> Coordinate? in
                    guard (xVariance != yVariance || xVariance != 0) else {
                        return nil
                    }

                    return Coordinate(x: self.x + xVariance, y: self.y + yVariance)
                })
            })
        }

        var position: Int {
            let s = Side(coordinate: self)

            // Ring and Column flip based on top/bottom vs left/right
            let (r, c) = { () -> (Int, Int) in
                switch s {
                case .top, .bottom: return (abs(self.y), self.x)
                case .left, .right: return (abs(self.x), self.y)
                }
            }()

            return Geometry.maxValue(forRing: r) - Geometry.midpointOffset(side: s, ring: r) - (s.directionality * c)
        }
    }

    enum Side: Int {
        case bottom = 0, left, top, right

        // The 3 and 6 o'clock sides walk in the "opposite" direction from center
        // I.E. adding one in the movement axis actually _decreases_ your "position" value
        var directionality: Int {
            return (self == .bottom || self == .right) ? -1 : 1
        }

        init?(position pos: Int) {
            guard (pos > 0) else {
                assertionFailure("Position \(pos) is invalid - must be greater than 0")
                return nil
            }

            let r = Geometry.ring(forPosition: pos)
            // Side is floor((ringMax - p) / (2r)). Should always be in [0,3] range, but be safe anyways
            let rawSide = Int(Double(Geometry.maxValue(forRing: r) - pos) / Double(2 * r))
            guard (0...3).contains(rawSide) else {
                assertionFailure("Impossible state while calculating side for position")
                return nil
            }

            self.init(rawValue: rawSide)
        }

        // Get the side of the square a given coordinate is on
        init(coordinate c: Coordinate) {
            // Special case the bottom right corner and 0,0 as .bottom
            if (c.x == -1 * c.y && c.x >= 0) {
                self = .bottom
            }
            // Whole right side (minus bottom right)
            else if (c.x > 0 && c.x >= abs(c.y)) {
                self = .right
            }
            // Whole top (minus top right)
            else if (c.y > 0 && c.y >= abs(c.x)) {
                self = .top
            }
            // Whole left (minus top left)
            else if (c.x < 0 && (-1 * c.x) >= abs(c.y)) {
                self = .left
            }
            // What remains should be bottom (minus bottom left)
            else {
                if !(c.y < 0 && (-1 * c.y) >= abs(c.x)) {
                    assertionFailure("Impossible state while calculating side for coord")
                }
                self = .bottom
            }
        }
    }

    // Helper geometry functions for position to ring and location to position conversions
    enum Geometry {
        static func ring(forPosition pos: Int) -> Int {
            guard (pos > 0) else { return -1 }

            let root = sqrt(Double(pos))
            // Perfect squares get halved and floored, others get floored, halved, then ceiled
            if (root.truncatingRemainder(dividingBy: 1) == 0) {
                return Int(floor(root / 2))
            } else {
                return Int(ceil(floor(root) / 2))
            }
        }

        static func midpointOffset(side: Side, ring: Int) -> Int {
            return (2 * side.rawValue + 1) * ring
        }

        static func maxValue(forRing r: Int) -> Int {
            // Ring r maxes out at position (2r+1)^2
            return (2 * r + 1) * (2 * r + 1)
        }
    }
}

// Solution to Part 1
let coordinate = SpiralStorage.Coordinate(position: input)!
let steps = abs(coordinate.x) + abs(coordinate.y)
print("It will take \(steps) steps to get back to origin from \(input)")

// Solution to Part 2
let storage = SpiralStorage()
func stressTest(position: Int) -> Int {
    // Short cut position 1 (and invalid positions) to value 1
    if (position <= 1) {
        storage.set(value: 1, toPosition: 1)
        return 1
    }

    // If we've already calculated this stress square, escape
    if let alreadyBuilt = storage.get(atPosition: position) {
        return alreadyBuilt
    }

    let sum = SpiralStorage.Coordinate(position: position)?.adjacent.reduce(0, { (soFar, coordinate) -> Int in
        guard coordinate.position < position else {
            return soFar
        }

        // Recurse to fill holes and get performance savings
        return soFar + stressTest(position: coordinate.position)
    }) ?? -1

    storage.set(value: sum, toPosition: position)
    return sum
}

var result = 0
var stressTestPosition = 0
while (result < input) {
    stressTestPosition += 1
    result = stressTest(position: stressTestPosition)
}

print("The first stress test value bigger than \(input) is \(result), written at position \(stressTestPosition)")
