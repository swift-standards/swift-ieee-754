extension IEEE_754 {

    public enum NextOperations {}
}

extension IEEE_754.NextOperations {

    public enum Direction: Sendable, Equatable {

        case toward(Target)
    }

    @inlinable
    public static func next(_ value: Double, direction: Direction) -> Double {
        switch direction {
        case .toward(.positiveInfinity):
            return value.nextUp

        case .toward(.negativeInfinity):
            return value.nextDown

        case .toward(.value(let target)):
            return nextAfter(value, toward: target)
        }
    }

    @inlinable
    public static func next(_ value: Float, direction: Direction) -> Float {
        switch direction {
        case .toward(.positiveInfinity):
            return value.nextUp

        case .toward(.negativeInfinity):
            return value.nextDown

        case .toward(.value(let target)):
            return nextAfter(value, toward: Float(target))
        }
    }
}

extension IEEE_754.NextOperations {

    @inlinable
    public static func nextUp(_ value: Double) -> Double {
        next(value, direction: .toward(.positiveInfinity))
    }

    @inlinable
    public static func nextDown(_ value: Double) -> Double {
        next(value, direction: .toward(.negativeInfinity))
    }

    @inlinable
    public static func nextAfter(_ value: Double, toward target: Double) -> Double {

        if value.isNaN || target.isNaN {
            return .nan
        }

        if value == target {

            if value.isZero && target.isZero && value.sign != target.sign {

                return target
            }
            return value
        }

        return value < target ? value.nextUp : value.nextDown
    }
}

extension IEEE_754.NextOperations.Direction {

    public enum Target: Sendable, Equatable {

        case positiveInfinity

        case negativeInfinity

        case value(Double)
    }
}

extension IEEE_754.NextOperations.Direction.Target {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.positiveInfinity, .positiveInfinity):
            return true

        case (.negativeInfinity, .negativeInfinity):
            return true

        case (.value(let l), .value(let r)):
            return l.bitPattern == r.bitPattern

        default:
            return false
        }
    }
}

extension IEEE_754.NextOperations {

    @inlinable
    public static func nextUp(_ value: Float) -> Float {
        next(value, direction: .toward(.positiveInfinity))
    }

    @inlinable
    public static func nextDown(_ value: Float) -> Float {
        next(value, direction: .toward(.negativeInfinity))
    }

    @inlinable
    public static func nextAfter(_ value: Float, toward target: Float) -> Float {
        if value.isNaN || target.isNaN {
            return .nan
        }

        if value == target {
            if value.isZero && target.isZero && value.sign != target.sign {
                return target
            }
            return value
        }

        return value < target ? value.nextUp : value.nextDown
    }
}
