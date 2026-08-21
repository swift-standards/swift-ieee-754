extension IEEE_754.Rounding {

    public enum Mode: Sendable, Hashable, CaseIterable {

        case positive

        case negative

        case zero

        case magnitude

        case nearest

        case away

        case toward
    }
}

extension IEEE_754.Rounding.Mode {

    public static var `default`: Self { .nearest }
}
