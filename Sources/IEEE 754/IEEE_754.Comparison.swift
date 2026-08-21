#if IEEE_754_SHIMS
    import IEEE_754_Shims
#endif

extension IEEE_754 {

    public enum Comparison {}
}

extension IEEE_754.Comparison {

    public enum Predicate: Sendable, Equatable {

        case equality(EqualityMode)

        case ordering(OrderingMode)
    }

    @inlinable
    public static func compare(_ lhs: Double, _ rhs: Double, using predicate: Predicate) -> Bool {
        switch predicate {
        case .equality(.equal):
            return lhs == rhs

        case .equality(.notEqual):
            return lhs != rhs

        case .ordering(.less(orEqual: false)):
            return lhs < rhs

        case .ordering(.less(orEqual: true)):
            return lhs <= rhs

        case .ordering(.greater(orEqual: false)):
            return lhs > rhs

        case .ordering(.greater(orEqual: true)):
            return lhs >= rhs
        }
    }

    @inlinable
    public static func compare(_ lhs: Float, _ rhs: Float, using predicate: Predicate) -> Bool {
        switch predicate {
        case .equality(.equal):
            return lhs == rhs

        case .equality(.notEqual):
            return lhs != rhs

        case .ordering(.less(orEqual: false)):
            return lhs < rhs

        case .ordering(.less(orEqual: true)):
            return lhs <= rhs

        case .ordering(.greater(orEqual: false)):
            return lhs > rhs

        case .ordering(.greater(orEqual: true)):
            return lhs >= rhs
        }
    }
}

extension IEEE_754.Comparison.Predicate {

    public enum EqualityMode: Sendable, Equatable {

        case equal

        case notEqual
    }

    public enum OrderingMode: Sendable, Equatable {

        case less(orEqual: Bool)

        case greater(orEqual: Bool)
    }
}

extension IEEE_754.Comparison {

    @inlinable
    public static func isEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .equality(.equal))
    }

    @inlinable
    public static func isNotEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .equality(.notEqual))
    }

    @inlinable
    public static func isLess(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: false)))
    }

    @inlinable
    public static func isLessEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: true)))
    }

    @inlinable
    public static func isGreater(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: false)))
    }

    @inlinable
    public static func isGreaterEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: true)))
    }

    @inlinable
    public static func totalOrder(_ lhs: Double, _ rhs: Double) -> Bool {
        lhs.isTotallyOrdered(belowOrEqualTo: rhs)
    }

    @inlinable
    public static func totalOrderMag(_ lhs: Double, _ rhs: Double) -> Bool {
        lhs.magnitude.isTotallyOrdered(belowOrEqualTo: rhs.magnitude)
    }
}

extension IEEE_754.Comparison {

    @inlinable
    public static func isEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .equality(.equal))
    }

    @inlinable
    public static func isNotEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .equality(.notEqual))
    }

    @inlinable
    public static func isLess(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: false)))
    }

    @inlinable
    public static func isLessEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: true)))
    }

    @inlinable
    public static func isGreater(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: false)))
    }

    @inlinable
    public static func isGreaterEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: true)))
    }

    @inlinable
    public static func totalOrder(_ lhs: Float, _ rhs: Float) -> Bool {
        lhs.isTotallyOrdered(belowOrEqualTo: rhs)
    }

    @inlinable
    public static func totalOrderMag(_ lhs: Float, _ rhs: Float) -> Bool {
        lhs.magnitude.isTotallyOrdered(belowOrEqualTo: rhs.magnitude)
    }
}

#if IEEE_754_SHIMS
    extension IEEE_754.Comparison {

        @frozen
        public enum Signaling {}
    }

    extension IEEE_754.Comparison.Signaling {

        public static func equal(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_equal(lhs, rhs) != 0
        }

        public static func less(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less(lhs, rhs) != 0
        }

        public static func lessEqual(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less_equal(lhs, rhs) != 0
        }

        public static func greater(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater(lhs, rhs) != 0
        }

        public static func greaterEqual(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater_equal(lhs, rhs) != 0
        }

        public static func notEqual(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_not_equal(lhs, rhs) != 0
        }

        public static func equal(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_equal_f(lhs, rhs) != 0
        }

        public static func less(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less_f(lhs, rhs) != 0
        }

        public static func lessEqual(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less_equal_f(lhs, rhs) != 0
        }

        public static func greater(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater_f(lhs, rhs) != 0
        }

        public static func greaterEqual(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater_equal_f(lhs, rhs) != 0
        }

        public static func notEqual(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_not_equal_f(lhs, rhs) != 0
        }
    }
#endif
