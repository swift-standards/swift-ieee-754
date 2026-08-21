extension IEEE_754 {

    public enum Classification {}
}

extension IEEE_754.Classification {

    @inlinable
    public static func isSignMinus(_ value: Double) -> Bool {
        value.sign == .minus
    }

    @inlinable
    public static func isNormal(_ value: Double) -> Bool {
        value.isNormal
    }

    @inlinable
    public static func isFinite(_ value: Double) -> Bool {
        value.isFinite
    }

    @inlinable
    public static func isZero(_ value: Double) -> Bool {
        value.isZero
    }

    @inlinable
    public static func isSubnormal(_ value: Double) -> Bool {
        value.isSubnormal
    }

    @inlinable
    public static func isInfinite(_ value: Double) -> Bool {
        value.isInfinite
    }

    @inlinable
    public static func isNaN(_ value: Double) -> Bool {
        value.isNaN
    }

    @inlinable
    public static func isSignaling(_ value: Double) -> Bool {
        value.isSignalingNaN
    }

    @inlinable
    public static func isCanonical(_ value: Double) -> Bool {
        value.isCanonical
    }

    @inlinable
    public static func radix(_ value: Double) -> Int {
        2
    }
}

extension IEEE_754.Classification {

    @inlinable
    public static func isSignMinus(_ value: Float) -> Bool {
        value.sign == .minus
    }

    @inlinable
    public static func isNormal(_ value: Float) -> Bool {
        value.isNormal
    }

    @inlinable
    public static func isFinite(_ value: Float) -> Bool {
        value.isFinite
    }

    @inlinable
    public static func isZero(_ value: Float) -> Bool {
        value.isZero
    }

    @inlinable
    public static func isSubnormal(_ value: Float) -> Bool {
        value.isSubnormal
    }

    @inlinable
    public static func isInfinite(_ value: Float) -> Bool {
        value.isInfinite
    }

    @inlinable
    public static func isNaN(_ value: Float) -> Bool {
        value.isNaN
    }

    @inlinable
    public static func isSignaling(_ value: Float) -> Bool {
        value.isSignalingNaN
    }

    @inlinable
    public static func isCanonical(_ value: Float) -> Bool {
        value.isCanonical
    }

    @inlinable
    public static func radix(_ value: Float) -> Int {
        2
    }
}

extension IEEE_754.Classification {

    public enum NumberClass: Sendable, Equatable {

        case nan(NaN)

        case positive(Finite)

        case negative(Finite)
    }

    @inlinable
    public static func numberClass(_ value: Double) -> NumberClass {
        if value.isNaN {
            return .nan(value.isSignalingNaN ? .signaling : .quiet)
        }

        let kind: NumberClass.Finite
        if value.isInfinite {
            kind = .infinity
        } else if value.isZero {
            kind = .zero
        } else if value.isSubnormal {
            kind = .subnormal
        } else {
            kind = .normal
        }

        return value.sign == .minus ? .negative(kind) : .positive(kind)
    }

    @inlinable
    public static func numberClass(_ value: Float) -> NumberClass {
        if value.isNaN {
            return .nan(value.isSignalingNaN ? .signaling : .quiet)
        }

        let kind: NumberClass.Finite
        if value.isInfinite {
            kind = .infinity
        } else if value.isZero {
            kind = .zero
        } else if value.isSubnormal {
            kind = .subnormal
        } else {
            kind = .normal
        }

        return value.sign == .minus ? .negative(kind) : .positive(kind)
    }
}

extension IEEE_754.Classification.NumberClass {

    public enum NaN: Sendable, Equatable {

        case signaling

        case quiet
    }

    public enum Finite: Sendable, Equatable {

        case infinity

        case normal

        case subnormal

        case zero
    }
}
