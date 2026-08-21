extension IEEE_754 {

    public enum MinMax {}
}

extension IEEE_754.MinMax {

    public enum Operation: Sendable, Equatable {

        case standard(Mode)

        case number(Mode)

        case magnitude(Mode, preferNumber: Bool)
    }

    @inlinable
    public static func apply(_ x: Double, _ y: Double, operation: Operation) -> Double {
        switch operation {
        case .standard(.minimum):
            return minimum(x, y)

        case .standard(.maximum):
            return maximum(x, y)

        case .number(.minimum):
            return minimumNumber(x, y)

        case .number(.maximum):
            return maximumNumber(x, y)

        case .magnitude(.minimum, preferNumber: false):
            return minimumMagnitude(x, y)

        case .magnitude(.maximum, preferNumber: false):
            return maximumMagnitude(x, y)

        case .magnitude(.minimum, preferNumber: true):
            return minimumMagnitudeNumber(x, y)

        case .magnitude(.maximum, preferNumber: true):
            return maximumMagnitudeNumber(x, y)
        }
    }

    @inlinable
    public static func apply(_ x: Float, _ y: Float, operation: Operation) -> Float {
        switch operation {
        case .standard(.minimum):
            return minimum(x, y)

        case .standard(.maximum):
            return maximum(x, y)

        case .number(.minimum):
            return minimumNumber(x, y)

        case .number(.maximum):
            return maximumNumber(x, y)

        case .magnitude(.minimum, preferNumber: false):
            return minimumMagnitude(x, y)

        case .magnitude(.maximum, preferNumber: false):
            return maximumMagnitude(x, y)

        case .magnitude(.minimum, preferNumber: true):
            return minimumMagnitudeNumber(x, y)

        case .magnitude(.maximum, preferNumber: true):
            return maximumMagnitudeNumber(x, y)
        }
    }
}

extension IEEE_754.MinMax.Operation {

    public enum Mode: Sendable, Equatable {

        case minimum

        case maximum
    }
}

extension IEEE_754.MinMax {

    @inlinable
    public static func minimum(_ x: Double, _ y: Double) -> Double {

        if x.isNaN || y.isNaN {
            return .nan
        }

        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }

        return x < y ? x : y
    }

    @inlinable
    public static func maximum(_ x: Double, _ y: Double) -> Double {

        if x.isNaN || y.isNaN {
            return .nan
        }

        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }

        return x > y ? x : y
    }

    @inlinable
    public static func minimumNumber(_ x: Double, _ y: Double) -> Double {

        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }

        return x < y ? x : y
    }

    @inlinable
    public static func maximumNumber(_ x: Double, _ y: Double) -> Double {

        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }

        return x > y ? x : y
    }

    @inlinable
    public static func minimumMagnitude(_ x: Double, _ y: Double) -> Double {

        if x.isNaN || y.isNaN {
            return .nan
        }

        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)

        if xMag < yMag {
            return x
        } else if yMag < xMag {
            return y
        } else {

            return minimum(x, y)
        }
    }

    @inlinable
    public static func maximumMagnitude(_ x: Double, _ y: Double) -> Double {

        if x.isNaN || y.isNaN {
            return .nan
        }

        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)

        if xMag > yMag {
            return x
        } else if yMag > xMag {
            return y
        } else {

            return maximum(x, y)
        }
    }

    @inlinable
    public static func minimumMagnitudeNumber(_ x: Double, _ y: Double) -> Double {

        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        return minimumMagnitude(x, y)
    }

    @inlinable
    public static func maximumMagnitudeNumber(_ x: Double, _ y: Double) -> Double {

        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        return maximumMagnitude(x, y)
    }
}

extension IEEE_754.MinMax {

    @inlinable
    public static func minimum(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }
        return x < y ? x : y
    }

    @inlinable
    public static func maximum(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }
        return x > y ? x : y
    }

    @inlinable
    public static func minimumNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }
        return x < y ? x : y
    }

    @inlinable
    public static func maximumNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }
        return x > y ? x : y
    }

    @inlinable
    public static func minimumMagnitude(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)
        if xMag < yMag {
            return x
        } else if yMag < xMag {
            return y
        } else {
            return minimum(x, y)
        }
    }

    @inlinable
    public static func maximumMagnitude(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)
        if xMag > yMag {
            return x
        } else if yMag > xMag {
            return y
        } else {
            return maximum(x, y)
        }
    }

    @inlinable
    public static func minimumMagnitudeNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        return minimumMagnitude(x, y)
    }

    @inlinable
    public static func maximumMagnitudeNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        return maximumMagnitude(x, y)
    }
}
