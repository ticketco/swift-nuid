import Foundation

#if os(Linux)
import Glibc
#else
import Security
#endif

let DIGITS = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".utf8)
let BASE = 62
let PRE_LEN = 12
let SEQ_LEN = 10
let MAX_SEQ = Int64(839_299_365_868_340_224)  // base^seqLen == 62^10
let MIN_INC = Int64(33)
let MAX_INC = Int64(333)
let TOTAL_LEN = PRE_LEN + SEQ_LEN

public class Nuid {
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

        // Set the prefix part
        b.replaceSubrange(0..<PRE_LEN, with: self.pre)

        // Set the sequence part
        var i = TOTAL_LEN - 1
        var l = seq
        while i >= PRE_LEN {
            b[i] = DIGITS[Int(l % Int64(BASE))]
            l /= Int64(BASE)
            i -= 1
        }

        return String(decoding: b, as: UTF8.self)
    }

    func resetSequential() {
        self.seq = Int64.random(in: 0..<MAX_SEQ)
        self.inc = MIN_INC + Int64.random(in: 0..<(MAX_INC - MIN_INC))
    }

    func randomizePrefix() {
        var cb = [UInt8](repeating: 0, count: PRE_LEN)
        generateSecureRandomBytes(&cb, count: PRE_LEN)

        for i in 0..<PRE_LEN {
            self.pre[i] = DIGITS[Int(cb[i]) % BASE]
        }
    }

    private func generateSecureRandomBytes(_ buffer: inout [UInt8], count: Int) {
        #if os(Linux)
        // Use /dev/urandom for Linux
        let file = fopen("/dev/urandom", "rb")
        guard file != nil else {
            fatalError("nuid: failed to open /dev/urandom")
        }
        defer { fclose(file) }

        let bytesRead = fread(&buffer, 1, count, file)
        guard bytesRead == count else {
            fatalError("nuid: failed to read random bytes from /dev/urandom")
        }
        #else
        // Use SecRandomCopyBytes for macOS
        let result = SecRandomCopyBytes(kSecRandomDefault, count, &buffer)
        guard result == errSecSuccess else {
            fatalError("nuid: failed generating crypto random number")
        }
        #endif
    }
}

class LockedNuid {
    private var lock = NSLock()
    var nuid: Nuid

    init() {
        self.nuid = Nuid()
    }

    func next() -> String {
        lock.lock()
        defer { lock.unlock() }
        return nuid.next()
    }
}

// Global NUID
var globalNUID = LockedNuid()

// Generate the next NUID string from the global locked NUID instance.
public func nextNuid() -> String {
    return globalNUID.next()
}

// Generate a new NUID instance.
public func newNuid() -> Nuid {
    return Nuid()
}
