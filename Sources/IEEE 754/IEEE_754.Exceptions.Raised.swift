extension IEEE_754.Exceptions {

    public struct Raised: Sendable {
        @usableFromInline
        internal init() {}
    }

    public static var raised: Raised { Raised() }
}

extension IEEE_754.Exceptions.Raised {

    @inlinable
    public var any: Bool {
        IEEE_754.Exceptions.Flag.allCases.contains { IEEE_754.Exceptions.test($0) }
    }

    @inlinable
    public var flags: [IEEE_754.Exceptions.Flag] {
        IEEE_754.Exceptions.Flag.allCases.filter { IEEE_754.Exceptions.test($0) }
    }
}
