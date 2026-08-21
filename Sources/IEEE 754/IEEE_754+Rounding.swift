extension IEEE_754 {

    public enum Rounding {}
}

extension IEEE_754.Rounding {

    public enum Direction: Sendable, Equatable {

        case towardInfinity(Sign)

        case towardZero

        case toNearest(TieBreaking)
    }

    @inlinable
    public static func apply(_ value: Double, direction: Direction) -> Double {
        switch direction {
        case .towardInfinity(.negative):
            return value.rounded(.down)

        case .towardInfinity(.positive):
            return value.rounded(.up)

        case .towardZero:
            return value.rounded(.towardZero)

        case .toNearest(.toEven):
            return value.rounded(.toNearestOrEven)

        case .toNearest(.awayFromZero):
            return value.rounded(.toNearestOrAwayFromZero)
        }
    }

    @inlinable
    public static func apply(_ value: Float, direction: Direction) -> Float {
        switch direction {
        case .towardInfinity(.negative):
            return value.rounded(.down)

        case .towardInfinity(.positive):
            return value.rounded(.up)

        case .towardZero:
            return value.rounded(.towardZero)

        case .toNearest(.toEven):
            return value.rounded(.toNearestOrEven)

        case .toNearest(.awayFromZero):
            return value.rounded(.toNearestOrAwayFromZero)
        }
    }
}

extension IEEE_754.Rounding.Direction {

    public enum Sign: Sendable, Equatable {

        case positive

        case negative
    }

    public enum TieBreaking: Sendable, Equatable {

        case toEven

        case awayFromZero
    }
}

extension IEEE_754.Rounding {

    @inlinable
    public static func floor(_ value: Double) -> Double {
        apply(value, direction: .towardInfinity(.negative))
    }

    @inlinable
    public static func ceil(_ value: Double) -> Double {
        apply(value, direction: .towardInfinity(.positive))
    }

    @inlinable
    public static func round(_ value: Double) -> Double {
        apply(value, direction: .toNearest(.toEven))
    }

    @inlinable
    public static func trunc(_ value: Double) -> Double {
        apply(value, direction: .towardZero)
    }

    @inlinable
    public static func roundAwayFromZero(_ value: Double) -> Double {
        apply(value, direction: .toNearest(.awayFromZero))
    }
}

extension IEEE_754.Rounding {

    @inlinable
    public static func floor(_ value: Float) -> Float {
        apply(value, direction: .towardInfinity(.negative))
    }

    @inlinable
    public static func ceil(_ value: Float) -> Float {
        apply(value, direction: .towardInfinity(.positive))
    }

    @inlinable
    public static func round(_ value: Float) -> Float {
        apply(value, direction: .toNearest(.toEven))
    }

    @inlinable
    public static func trunc(_ value: Float) -> Float {
        apply(value, direction: .towardZero)
    }

    @inlinable
    public static func roundAwayFromZero(_ value: Float) -> Float {
        apply(value, direction: .toNearest(.awayFromZero))
    }
}

extension Double.IEEE754 {

    public var floor: Double {
        IEEE_754.Rounding.floor(double)
    }

    public var ceil: Double {
        IEEE_754.Rounding.ceil(double)
    }

    public var round: Double {
        IEEE_754.Rounding.round(double)
    }

    public var trunc: Double {
        IEEE_754.Rounding.trunc(double)
    }

    public var roundAwayFromZero: Double {
        IEEE_754.Rounding.roundAwayFromZero(double)
    }
}

extension Float.IEEE754 {

    public var floor: Float {
        IEEE_754.Rounding.floor(float)
    }

    public var ceil: Float {
        IEEE_754.Rounding.ceil(float)
    }

    public var round: Float {
        IEEE_754.Rounding.round(float)
    }

    public var trunc: Float {
        IEEE_754.Rounding.trunc(float)
    }

    public var roundAwayFromZero: Float {
        IEEE_754.Rounding.roundAwayFromZero(float)
    }
}
