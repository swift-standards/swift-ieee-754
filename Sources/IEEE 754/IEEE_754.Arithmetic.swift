extension IEEE_754 {

    public enum Arithmetic {}
}

extension IEEE_754.Arithmetic {

    @inlinable
    public static func addition<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
        lhs + rhs
    }

    @inlinable
    public static func subtraction<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
        lhs - rhs
    }

    @inlinable
    public static func multiplication<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
        lhs * rhs
    }

    @inlinable
    public static func division<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
        lhs / rhs
    }

    @inlinable
    public static func remainder<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
        lhs.remainder(dividingBy: rhs)
    }
}

extension IEEE_754.Arithmetic {

    @inlinable
    public static func squareRoot<T: BinaryFloatingPoint>(_ value: T) -> T {
        value.squareRoot()
    }

    @inlinable
    public static func fusedMultiplyAdd<T: BinaryFloatingPoint>(a: T, b: T, c: T) -> T {
        c.addingProduct(a, b)
    }
}

extension IEEE_754.Arithmetic {

    @inlinable
    public static func absoluteValue<T: BinaryFloatingPoint>(_ value: T) -> T {
        abs(value)
    }

    @inlinable
    public static func negate<T: BinaryFloatingPoint>(_ value: T) -> T {
        -value
    }
}
