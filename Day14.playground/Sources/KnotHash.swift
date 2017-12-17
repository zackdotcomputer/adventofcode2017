import Foundation

extension String {
    func toBytes() -> [UInt8] {
        return self.utf8.map { $0 as UInt8 }
    }
}

public class KnotHash {
    private enum Constants {
        static let standardSuffix: [Int] = [17, 31, 73, 47, 23]
        static let roundRepeatCount = 64
        static let blockSize = 16
        static let blockCount = 16
    }

    // In hindsight, this class was a little too stateful that I needed this class func to do the hash...
    public class func hash(value: String) -> String {
        let me = KnotHash()
        return me.calculateHash(value: value)
    }

    private var currentPosition: Int = 0
    private var skipSize: Int = 0

    private var ring: [UInt16] = Array(0..<UInt16(Constants.blockSize * Constants.blockCount))

    private func calculateHash(value: String) -> String {
        let lengths: [Int] = value.toBytes().map({ Int($0) }) + Constants.standardSuffix
        for _ in 0..<Constants.roundRepeatCount {
            lengths.forEach({ handle(length: $0) })
        }
        return self.denseHash
    }

    fileprivate func handle(length: Int) {
        // example: cp of 2, length of 2, ring of 4, range is 2 and 3, overlap is 0
        // example: cp of 2, length of 3, ring of 4, range is 2, 3 | 0, so overlap is 1
        let overlap = max((currentPosition + length) - ring.count, 0)

        let flippedArray = Array((ring[currentPosition..<(currentPosition + length - overlap)] + ring[0..<overlap]).reversed())
        ring[currentPosition..<(currentPosition + length - overlap)] = flippedArray[0..<(length - overlap)]
        ring[0..<overlap] = flippedArray[(length - overlap)..<length]

        currentPosition = (currentPosition + length + skipSize) % ring.count
        skipSize += 1
    }

    private var denseHash: String {
        get {
            var denseComponents: [UInt16] = []
            for block in (0..<Constants.blockCount) {
                let nextBlock = ring[((block * Constants.blockSize) + 1)..<((block + 1) * Constants.blockSize)]
                let nextComponent = nextBlock.reduce(ring[block * Constants.blockSize], ^)
                denseComponents.append(nextComponent)
            }
            return denseComponents.map({
                let result = String(format:"%2X", $0).trimmingCharacters(in: CharacterSet.whitespaces)
                if (result.count == 2) {
                    return result
                } else if (result.count == 1) {
                    return "0" + result
                } else {
                    return "00"
                }
            }).joined()
        }
    }

    fileprivate var hashChecksum: Int {
        get {
            return Int(ring[0]) * Int(ring[1])
        }
    }
}
