import Foundation

let DIGITS = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".utf8)
let BASE = 62
let PRE_LEN = 12
let SEQ_LEN = 10
let MAX_SEQ = Int64(839_299_365_868_340_224)  // base^seqLen == 62^10
let MIN_INC = Int64(33)
let MAX_INC = Int64(333)
let TOTAL_LEN = PRE_LEN + SEQ_LEN

public class NUID {
    var pre: [UInt8]
    var seq: Int64
    var inc: Int64

    init() {
        self.pre = [UInt8](repeating: 0, count: PRE_LEN)
        self.seq = Int64.random(in: 0..<MAX_SEQ)
        self.inc = MIN_INC + Int64.random(in: 0..<(MAX_INC - MIN_INC))
        self.randomizePrefix()
    }

    public func next() -> String {
        self.seq += self.inc
        if self.seq >= MAX_SEQ {
            self.randomizePrefix()
            self.resetSequential()
        }
        let seq = self.seq

        var b = [UInt8](repeating: 0, count: TOTAL_LEN)
        var bs = b[0..<PRE_LEN]
        bs.replaceSubrange(bs.startIndex..<bs.endIndex, with: self.pre)

        var i = b.count
        var l = seq
        while i > PRE_LEN {
            i -= 1
            b[i] = DIGITS[Int(l % Int64(BASE))]
            l /= Int64(BASE)
        }

        return String(decoding: b, as: UTF8.self)
    }

    func resetSequential() {
        self.seq = Int64.random(in: 0..<MAX_SEQ)
        self.inc = MIN_INC + Int64.random(in: 0..<(MAX_INC - MIN_INC))
    }

    public func randomizePrefix() {
        var cb = [UInt8](repeating: 0, count: PRE_LEN)
        let result = SecRandomCopyBytes(kSecRandomDefault, PRE_LEN, &cb)

        if result != errSecSuccess {
            fatalError("nuid: failed generating crypto random number")
        }

        for i in 0..<PRE_LEN {
            self.pre[i] = DIGITS[Int(cb[i]) % BASE]
        }
    }
}

class LockedNUID {
    private var lock = NSLock()
    var nuid: NUID

    init() {
        self.nuid = NUID()
    }

    func next() -> String {
        lock.lock()
        defer { lock.unlock() }
        return nuid.next()
    }
}

// Global NUID
var globalNUID = LockedNUID()

// Generate the next NUID string from the global locked NUID instance.
public func Next() -> String {
    return globalNUID.next()
}

// Generate a new NUID instance.
public func New() -> NUID {
    return NUID()
}
