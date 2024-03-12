import XCTest

@testable import Nuid

final class NuidTests: XCTestCase {
    func testDigits() {
        XCTAssertEqual(DIGITS.count, BASE, "Digits length does not match base modulo")
    }

    func testGlobalNUIDInit() {
        XCTAssertNotNil(globalNUID, "Expected globalNUID to be non-nil")
        XCTAssertEqual(globalNUID.nuid.pre.count, PRE_LEN, "Expected prefix to be initialized")
        XCTAssertNotEqual(globalNUID.nuid.seq, 0, "Expected seq to be non-zero")
    }

    func testNUIDRollover() {
        globalNUID.nuid.seq = MAX_SEQ
        let oldPre = globalNUID.nuid.pre
        _ = Next()
        XCTAssertNotEqual(globalNUID.nuid.pre, oldPre, "Expected new pre, got the old one")
    }

    func testGUIDLen() {
        let nuid = Next()
        XCTAssertEqual(nuid.count, TOTAL_LEN, "Expected len of \(TOTAL_LEN), got \(nuid.count)")
    }

    func testProperPrefix() {
        var min: UInt8 = 255
        var max: UInt8 = 0

        for digit in DIGITS {
            if digit < min {
                min = digit
            }
            if digit > max {
                max = digit
            }
        }

        let total = 100000

        for _ in 0..<total {
            let n = New()
            for j in 0..<PRE_LEN {
                XCTAssertGreaterThanOrEqual(
                    n.pre[j], min, "Valid range for bytes prefix: [\(min)..\(max)]")
                XCTAssertLessThanOrEqual(
                    n.pre[j], max, "Valid range for bytes prefix: [\(min)..\(max)]")
            }
        }
    }
}
