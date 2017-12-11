// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

enum HexDirection: String {
    case n = "n",
    ne = "ne",
    nw = "nw",
    s = "s",
    se = "se",
    sw = "sw"

    var negative: HexDirection {
        switch self {
        case .n: return .s
        case .ne: return .sw
        case .nw: return .se
        case .s: return .n
        case .se: return .nw
        case .sw: return .ne
        }
    }

    var unitVectorNortherly: HexVector {
        switch self {
        case .n, .ne, .nw: return HexVector(direction: self, distance: 1)
        case .s, .se, .sw: return HexVector(direction: self.negative, distance: -1)
        }
    }
}

struct HexVector {
    var direction: HexDirection
    var distance: Int

    var isZero: Bool {
        return self.distance == 0
    }

    var isNegative: Bool {
        return self.distance < 0
    }
}

// A hex coordinate is like a polar coordinate but composed of three vectors summed from the origin
struct HexCoordinate {
    var vectorDue: HexVector = HexVector(direction: .n, distance: 0)
    var vectorEasterly: HexVector = HexVector(direction: .ne, distance: 0)
    var vectorWesterly: HexVector = HexVector(direction: .nw, distance: 0)

    var distanceToOrigin: Int {
        return abs(vectorDue.distance) + abs(vectorEasterly.distance) + abs(vectorWesterly.distance)
    }

    mutating func oneStep(inDirection dir: HexDirection) {
        let vectorToAdd = dir.unitVectorNortherly
        switch vectorToAdd.direction {
        case .n:
            self.vectorDue.distance += vectorToAdd.distance
            break
        case .ne:
            self.vectorEasterly.distance += vectorToAdd.distance
            break
        case .nw:
            self.vectorWesterly.distance += vectorToAdd.distance
            break
        default:
            assertionFailure("Northerly vector wasn't northerly")
        }

        self.reduceSteps()
    }

    // Theory: any hex coordinate can actually be reduced to TWO elements by removing the lesser element into the other two...
    // The idea being if you went 10 steps north, 4 nw, and 8 ne, the 4 nw and 4 of the ne actually cancel out into...
    // 4 northerly steps? Ok so yes... I think that works. The reduceable axis is always the middle one, though.
    // And you need two at 120 degrees with complementary movement
    mutating func reduceSteps() {
        // Reduce to north
        if (vectorEasterly.isNegative == vectorWesterly.isNegative && vectorEasterly.isZero == vectorWesterly.isZero) {
            let lesserValue = min(abs(vectorEasterly.distance), abs(vectorWesterly.distance)) * (vectorEasterly.isNegative ? -1 : 1)
            vectorEasterly.distance -= lesserValue
            vectorWesterly.distance -= lesserValue
            vectorDue.distance += lesserValue
        }
        // Reduce to the ne
        else if (vectorDue.isNegative != vectorWesterly.isNegative && vectorDue.isZero == vectorWesterly.isZero) {
            let lesserValue = min(abs(vectorDue.distance), abs(vectorWesterly.distance)) * (vectorDue.isNegative ? -1 : 1)
            vectorDue.distance -= lesserValue
            vectorWesterly.distance += lesserValue
            vectorEasterly.distance += lesserValue
        }
        else if (vectorDue.isNegative != vectorEasterly.isNegative && vectorDue.isZero == vectorEasterly.isZero) {
            let lesserValue = min(abs(vectorDue.distance), abs(vectorEasterly.distance)) * (vectorDue.isNegative ? -1 : 1)
            vectorDue.distance -= lesserValue
            vectorWesterly.distance += lesserValue
            vectorEasterly.distance += lesserValue
        }
    }
}

let input = try String(contentsOf: Bundle.main.url(forResource: "input", withExtension: "txt")!,
                       encoding: String.Encoding.utf8).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    .split(separator: ",")
    .flatMap({ HexDirection.init(rawValue: String($0)) })
// I had an empty array for faster testing
//let input: [HexDirection] = []

// Solution to part 1
// AND Solution to part 2
var endpoint = HexCoordinate()
let distances = input.map { (dir) -> Int in
    endpoint.oneStep(inDirection: dir)
    return endpoint.distanceToOrigin
}
let farthest = distances.max() ?? -1
let stepsToArrive = distances.last ?? -1
print("it will take \(stepsToArrive) steps")
print("You were at farthest, \(farthest) steps")
