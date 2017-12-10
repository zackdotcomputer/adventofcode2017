//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt")
let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

// Need a way to turn a string into an int array
extension String {
    func cellTokenize() -> [[String]] {
        return self.split(separator: "\n").flatMap({ (substr) -> [String]? in
            guard substr.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 else {
                return nil
            }

            return substr.split(separator: "\t").map({ String($0) })
        })
    }
}

// Part 1 solution
func checksum(_ input: String) -> Int {
    let sheet = input.cellTokenize().map({ $0.flatMap({ Int($0) }) })

    return sheet.reduce(0, { (soFar, row) -> Int in
        guard let max = row.max(),
            let min = row.min() else {
                return soFar
        }

        return soFar + (max - min)
    })
}

checksum(content)

// Part 2 Solution
func checksum2(_ input: String) -> Int {
    let sheet = input.cellTokenize().map({ $0.flatMap({ Int($0) }) })

    return sheet.reduce(0, { (soFar, row) -> Int in
        for numerator in row {
            guard let denominator = row.first(where: { (numerator != $0) && (numerator % $0 == 0) }) else {
                continue
            }
            // If we got here, we found a denom who evenly divided into numer
            return soFar + (numerator / denominator)
        }
        return soFar
    })
}

checksum2(content)
