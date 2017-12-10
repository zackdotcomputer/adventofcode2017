//
// Created by: Zack Sheppard (@zackzachariah)
// No guarantees, but no restrictions either. Public domain code.
// Solutions to Advent of Calendar 2017
//

import Foundation

extension String {
    func cellTokenize() -> [[String]] {
        return self.split(separator: "\n").flatMap({ (substr) -> [String]? in
            guard substr.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 else {
                return nil
            }

            return substr.split(separator: " ").map({ String($0) })
        })
    }
}

func filterInvalid(passphrases: [[String]], allowAnagrams: Bool = true) -> [[String]] {
    return passphrases.filter({ (words) -> Bool in
        // Short circuit if we're just checking equality
        if (allowAnagrams) {
            return Set(words).count == words.count
        }

        let organizedWords = words.map({ (str) -> String in
            var letters: [String] = []
            for i: Int in 0..<str.count {
                let index = str.index(str.startIndex, offsetBy:i)
                letters.append(String(str[index]))
            }
            return letters.sorted().joined()
        })
        return Set(organizedWords).count == words.count
    })
}

let fileURL = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

var rows = input.cellTokenize()

// Answer to part 1
filterInvalid(passphrases: rows).count

// Answer to part 2
filterInvalid(passphrases: rows, allowAnagrams: false).count
