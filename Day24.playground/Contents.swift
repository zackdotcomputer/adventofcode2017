// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017

import Foundation

// The Data structure & algorithms

class Connector: Hashable {
    let ident: Int
    let ends: (Int, Int)
    var isForward: Bool = true

    public var hashValue: Int {
        return "\(ident),\(ends.0),\(ends.1)".hashValue
    }

    public static func ==(lhs: Connector, rhs: Connector) -> Bool {
        return lhs.ident == rhs.ident && lhs.endsArray == rhs.endsArray
    }

    var trailing: Int {
        return isForward ? ends.0 : ends.1
    }

    var leading: Int {
        return isForward ? ends.1 : ends.0
    }

    var endsArray: [Int] {
        return [ends.0, ends.1]
    }

    func otherEnd(fromConnector connector: Int) -> Int {
        if (ends.0 == connector) {
            return ends.1
        }
        else if (ends.1 == connector) {
            return ends.0
        }
        else {
            assertionFailure("Can't connect \(ends) to \(connector)")
            return -1
        }
    }

    init(_ end1: Int, _ end2: Int, identifier: Int) {
        ends = (min(end1, end2), max(end1, end2))
        ident = identifier
    }

    convenience init?(input: String, identifier: Int) {
        let separated = input.split(separator: "/").flatMap({ Int(String($0)) })
        guard separated.count == 2 else {
            return nil
        }

        self.init(separated[0], separated[1], identifier: identifier)
    }
}

extension Array where Element == Connector {
    var points: Int {
        return self.reduce(0) { (soFar, connector) -> Int in
            return soFar + connector.ends.0 + connector.ends.1
        }
    }
}

class ConnectorGraph {
    let tokenGraph: [Int : [Connector]]
    let allConnectors: Set<Connector>

    init(input: [String]) {
        var i = -1
        allConnectors = Set(input.flatMap({
            i += 1
            return Connector(input: $0, identifier: i)
        }))
        var tokensInProgress: [Int : [Connector]] = [:]
        for connector in allConnectors {
            tokensInProgress[connector.ends.0] = (tokensInProgress[connector.ends.0] ?? []) + [connector]
            tokensInProgress[connector.ends.1] = (tokensInProgress[connector.ends.1] ?? []) + [connector]
        }
        tokenGraph = tokensInProgress
    }

    func findStrongest() -> [Connector] {
        return walkForBest(exposedConnector: 0,
                           soFar: [],
                           unused: allConnectors,
                           optimization: { return $0.points < $1.points })
    }

    func findLongestStrongest() -> [Connector] {
        return walkForBest(exposedConnector: 0,
                           soFar: [],
                           unused: allConnectors,
                           optimization: { return $0.count < $1.count || ($0.count == $1.count && $0.points < $1.points) })
    }

    private func walkForBest(exposedConnector: Int,
                             soFar: [Connector],
                             unused: Set<Connector>,
                             optimization: (([Connector], [Connector]) -> Bool)) -> [Connector] {
        // If we have no more potential links, we're done
        guard let potentialsArray = tokenGraph[exposedConnector] else {
            return soFar
        }
        let potentials = Set(potentialsArray).intersection(unused)
        guard !potentials.isEmpty else {
            return soFar
        }

        let branches = potentials.map({ (nextLink) -> [Connector] in
            let link = [nextLink]
            let nextConnector = nextLink.otherEnd(fromConnector: exposedConnector)
            let bestChild = walkForBest(exposedConnector: nextConnector,
                                        soFar: soFar + link,
                                        unused: unused.subtracting(link),
                                        optimization: optimization)
            return bestChild
        })

        return (branches.max(by: optimization) ?? soFar)
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
                       encoding: String.Encoding.utf8).split(separator: "\n").map(String.init)

// Solution to part 1

func part1() {
    let graph = ConnectorGraph(input: input)
    let best = graph.findStrongest()
    let bestArray = best.map({ $0.endsArray })
    print("The best path found has strength \(best.points)")
    print("It was: \(bestArray)")
}
//part1()

// Solution to part 2

func part2() {
    let graph = ConnectorGraph(input: input)
    let best = graph.findLongestStrongest()
    let bestArray = best.map({ $0.endsArray })
    print("The best path found has strength \(best.points)")
    print("It was: \(bestArray)")
}
part2()

