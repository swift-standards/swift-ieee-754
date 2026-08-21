extension IEEE_754 {

    public enum Binary256 {}
}

extension IEEE_754.Binary256 {

    public static let byteSize: Int = 32

    public static let bitSize: Int = 256

    public static let signBits: Int = 1

    public static let exponentBits: Int = 19

    public static let significandBits: Int = 236

    public static let exponentBias: Int = 262143

    public static let maxExponent: Int = (1 << exponentBits) - 1

    public static let precision: Int = 237

    public static let emin: Int = -262142

    public static let emax: Int = 262143

    public static let decimalPrecision: Int = 71
}

extension IEEE_754.Binary256 {

    public enum SpecialValuesDocumentation {}
}
