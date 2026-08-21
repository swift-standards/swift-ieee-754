extension IEEE_754 {

    public struct Status: OptionSet, Sendable, Hashable {
        public var rawValue: UInt8

        @inlinable
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension IEEE_754.Status {

    public static let invalid = Self(rawValue: 1 << 0)

    public static let divisionByZero = Self(rawValue: 1 << 1)

    public static let overflow = Self(rawValue: 1 << 2)

    public static let underflow = Self(rawValue: 1 << 3)

    public static let inexact = Self(rawValue: 1 << 4)

    public static let none: Self = []
}

extension IEEE_754.Status {

    public static let divide = Self.divisionByZero
}
