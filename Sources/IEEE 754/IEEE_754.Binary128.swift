extension IEEE_754 {

    public enum Binary128 {}
}

extension IEEE_754.Binary128 {

    public static let byteSize: Int = 16

    public static let bitSize: Int = 128

    public static let signBits: Int = 1

    public static let exponentBits: Int = 15

    public static let significandBits: Int = 112

    public static let exponentBias: Int = 16383

    public static let maxExponent: Int = (1 << exponentBits) - 1

    public static let precision: Int = 113

    public static let emin: Int = -16382

    public static let emax: Int = 16383

    public static let decimalPrecision: Int = 34
}

extension IEEE_754.Binary128 {

    public enum SpecialValuesDocumentation {}
}
