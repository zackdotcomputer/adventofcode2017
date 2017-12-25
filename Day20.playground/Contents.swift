// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

struct Vector3d: Hashable {
    let x: Int
    let y: Int
    let z: Int

    var distance: Int {
        return abs(x) + abs(y) + abs(z)
    }

    public static func ==(lhs: Vector3d, rhs: Vector3d) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    public var hashValue: Int {
        return "\(x),\(y),\(z)".hashValue
    }

    static func + (left: Vector3d, right: Vector3d) -> Vector3d {
        return Vector3d(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    static func * (left: Vector3d, right: Int) -> Vector3d {
        return Vector3d(x: left.x + right, y: left.y + right, z: left.z + right)
    }
}

struct Moment {
    let position: Vector3d
    let acceleration: Vector3d
    let velocity: Vector3d

    var distance: Int {
        return position.distance
    }

    static func parse(input: String) -> Moment? {
        guard let triplePointPattern = try? NSRegularExpression(pattern: "([pva])=<(-?[0-9]+),(-?[0-9]+),(-?[0-9]+)>",
                                                                options: []) else { return nil }


        let matches = triplePointPattern.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
        guard matches.count == 3 else { return nil }

        var p, v, a: Vector3d?

        for match in matches {
            guard match.numberOfRanges == 5,
                let variableRange = Range(match.range(at: 1), in: input) else {
                return nil
            }
            let variable = input[variableRange]
            switch variable {
            case "p":
                p = getTriplePoint(fromMatch: match, input: input)
                break;
            case "v":
                v = getTriplePoint(fromMatch: match, input: input)
                break;
            case "a":
                a = getTriplePoint(fromMatch: match, input: input)
                break;
            default:
                break;
            }
        }

        guard let position = p, let velocity = v, let acceleration = a else {
            return nil
        }

        return Moment(position: position, acceleration: acceleration, velocity: velocity)
    }

    private static func getTriplePoint(fromMatch match: NSTextCheckingResult, input: String) -> Vector3d? {
        guard let xRange = Range(match.range(at: 2), in: input),
            let yRange = Range(match.range(at: 3), in: input),
            let zRange = Range(match.range(at: 4), in: input) else {
                return nil
        }

        guard let x = Int(input[xRange]), let y = Int(input[yRange]), let z = Int(input[zRange]) else {
            return nil
        }

        return Vector3d(x: x, y: y, z: z)
    }
}

class Particle {
    let initialMoment: Moment
    var currentMoment: Moment

    init(startingPoint: Moment) {
        initialMoment = startingPoint
        currentMoment = startingPoint
    }

    func after(time: Int) -> Moment {
        // Horizontal is x, y, z. Vertical is a, v, p
        let vPrime = (initialMoment.acceleration * time) + initialMoment.velocity
        let sPrime = (initialMoment.acceleration * ((time * (time + 1)) / 2)) + (initialMoment.velocity * time) + initialMoment.position

        return Moment(position: sPrime, acceleration: initialMoment.acceleration, velocity: vPrime)
    }

    func iterativeAfter(time: Int) -> Moment {
        var p = initialMoment.position
        var v = initialMoment.velocity
        let a = initialMoment.acceleration
        for _ in 0..<time {
            v = v + a
            p = p + v
        }

        return Moment(position: p, acceleration: a, velocity: v)
    }

    func tick() -> Moment {
        let v = currentMoment.velocity + initialMoment.acceleration
        let p = currentMoment.position + v

        currentMoment = Moment(position: p, acceleration: initialMoment.acceleration, velocity: v)
        return currentMoment
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
                       encoding: String.Encoding.utf8).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).split(separator: "\n")

// Solution to part 1

func part1() {
    let particles = input.flatMap({ Moment.parse(input: String($0)) }).map({ Particle(startingPoint: $0) })

    var minIndex = 0
    var minValue = Int.max
    for i in 0..<particles.count {
        let momentAfter = particles[i].iterativeAfter(time: 1000)
        let thisDistance = momentAfter.distance
        if thisDistance < minValue {
            minValue = thisDistance
            minIndex = i
        }
    }

    print("Particle \(minIndex) is closest in the long run")
}
//part1()

// Solution to part 2

func part2() {
    var particles = input.flatMap({ Moment.parse(input: String($0)) }).map({ Particle(startingPoint: $0) })

    let runCount = 100000

    for tick in 0..<runCount {
        if (tick % 1000 == 0) {
            print("Made it \(tick) ticks")
        }

        var positionState: [Vector3d : [Int]] = [:]

        // Find collisions
        for i in 0..<particles.count {
            let position = particles[i].tick().position
            positionState[position] = (positionState[position] ?? []) + [i]
        }

        // And resolve them
        let jumbledIndices: [[Int]] = positionState.values.filter({ $0.count > 1 })
        jumbledIndices.joined().sorted(by: >).forEach({ particles.remove(at: $0) })
    }

    print("After those runs, \(particles.count) particles remain")
}

part2()

