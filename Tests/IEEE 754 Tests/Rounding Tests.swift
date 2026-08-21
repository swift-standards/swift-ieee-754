import Testing

@testable import IEEE_754

extension IEEE_754.Rounding {
    @Suite("IEEE 754 Rounding Operations")
    struct Test {}
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (3.7, 3.0),
            (3.0, 3.0),
            (3.2, 3.0),
            (-3.2, -4.0),
            (-3.7, -4.0),
            (-3.0, -3.0),
            (0.0, 0.0),
            (-0.0, -0.0),
            (0.1, 0.0),
            (-0.1, -1.0),
        ])
    func `floor rounds toward negative infinity`(value: Double, expected: Double) {
        #expect(IEEE_754.Rounding.floor(value) == expected)
        #expect(value.ieee754.floor == expected)
    }

    @Test
    func `floor handles special values`() {
        #expect(IEEE_754.Rounding.floor(Double.infinity) == Double.infinity)
        #expect(IEEE_754.Rounding.floor(-Double.infinity) == -Double.infinity)
        #expect(IEEE_754.Rounding.floor(Double.nan).isNaN)
        #expect(IEEE_754.Rounding.floor(0.0) == 0.0)
        #expect(IEEE_754.Rounding.floor(-0.0) == -0.0)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (3.2, 4.0),
            (3.0, 3.0),
            (3.7, 4.0),
            (-3.7, -3.0),
            (-3.2, -3.0),
            (-3.0, -3.0),
            (0.0, 0.0),
            (-0.0, -0.0),
            (0.1, 1.0),
            (-0.1, -0.0),
        ])
    func `ceil rounds toward positive infinity`(value: Double, expected: Double) {
        #expect(IEEE_754.Rounding.ceil(value) == expected)
        #expect(value.ieee754.ceil == expected)
    }

    @Test
    func `ceil handles special values`() {
        #expect(IEEE_754.Rounding.ceil(Double.infinity) == Double.infinity)
        #expect(IEEE_754.Rounding.ceil(-Double.infinity) == -Double.infinity)
        #expect(IEEE_754.Rounding.ceil(Double.nan).isNaN)
        #expect(IEEE_754.Rounding.ceil(0.0) == 0.0)
        #expect(IEEE_754.Rounding.ceil(-0.0) == -0.0)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (3.4, 3.0),
            (3.5, 4.0),
            (3.6, 4.0),
            (4.5, 4.0),
            (5.5, 6.0),
            (-3.4, -3.0),
            (-3.5, -4.0),
            (-3.6, -4.0),
            (-4.5, -4.0),
            (-5.5, -6.0),
            (0.5, 0.0),
            (-0.5, -0.0),
        ])
    func `round rounds to nearest (ties to even)`(value: Double, expected: Double) {
        #expect(IEEE_754.Rounding.round(value) == expected)
        #expect(value.ieee754.round == expected)
    }

    @Test
    func `round handles special values`() {
        #expect(IEEE_754.Rounding.round(Double.infinity) == Double.infinity)
        #expect(IEEE_754.Rounding.round(-Double.infinity) == -Double.infinity)
        #expect(IEEE_754.Rounding.round(Double.nan).isNaN)
        #expect(IEEE_754.Rounding.round(0.0) == 0.0)
        #expect(IEEE_754.Rounding.round(-0.0) == -0.0)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (3.7, 3.0),
            (3.2, 3.0),
            (3.0, 3.0),
            (-3.2, -3.0),
            (-3.7, -3.0),
            (-3.0, -3.0),
            (0.0, 0.0),
            (-0.0, -0.0),
            (0.9, 0.0),
            (-0.9, -0.0),
        ])
    func `trunc rounds toward zero`(value: Double, expected: Double) {
        #expect(IEEE_754.Rounding.trunc(value) == expected)
        #expect(value.ieee754.trunc == expected)
    }

    @Test
    func `trunc handles special values`() {
        #expect(IEEE_754.Rounding.trunc(Double.infinity) == Double.infinity)
        #expect(IEEE_754.Rounding.trunc(-Double.infinity) == -Double.infinity)
        #expect(IEEE_754.Rounding.trunc(Double.nan).isNaN)
        #expect(IEEE_754.Rounding.trunc(0.0) == 0.0)
        #expect(IEEE_754.Rounding.trunc(-0.0) == -0.0)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (Float(3.7), Float(3.0)),
            (Float(3.0), Float(3.0)),
            (Float(-3.2), Float(-4.0)),
            (Float(-3.7), Float(-4.0)),
            (Float(0.0), Float(0.0)),
        ])
    func `float floor rounds toward negative infinity`(value: Float, expected: Float) {
        #expect(IEEE_754.Rounding.floor(value) == expected)
        #expect(value.ieee754.floor == expected)
    }

    @Test
    func `float floor handles special values`() {
        #expect(IEEE_754.Rounding.floor(Float.infinity) == Float.infinity)
        #expect(IEEE_754.Rounding.floor(-Float.infinity) == -Float.infinity)
        #expect(IEEE_754.Rounding.floor(Float.nan).isNaN)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (Float(3.2), Float(4.0)),
            (Float(3.0), Float(3.0)),
            (Float(-3.7), Float(-3.0)),
            (Float(-3.2), Float(-3.0)),
            (Float(0.0), Float(0.0)),
        ])
    func `float ceil rounds toward positive infinity`(value: Float, expected: Float) {
        #expect(IEEE_754.Rounding.ceil(value) == expected)
        #expect(value.ieee754.ceil == expected)
    }

    @Test
    func `float ceil handles special values`() {
        #expect(IEEE_754.Rounding.ceil(Float.infinity) == Float.infinity)
        #expect(IEEE_754.Rounding.ceil(-Float.infinity) == -Float.infinity)
        #expect(IEEE_754.Rounding.ceil(Float.nan).isNaN)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (Float(3.4), Float(3.0)),
            (Float(3.5), Float(4.0)),
            (Float(3.6), Float(4.0)),
            (Float(4.5), Float(4.0)),
            (Float(-3.5), Float(-4.0)),
            (Float(0.5), Float(0.0)),
        ])
    func `float round rounds to nearest (ties to even)`(value: Float, expected: Float) {
        #expect(IEEE_754.Rounding.round(value) == expected)
        #expect(value.ieee754.round == expected)
    }

    @Test
    func `float round handles special values`() {
        #expect(IEEE_754.Rounding.round(Float.infinity) == Float.infinity)
        #expect(IEEE_754.Rounding.round(-Float.infinity) == -Float.infinity)
        #expect(IEEE_754.Rounding.round(Float.nan).isNaN)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (Float(3.7), Float(3.0)),
            (Float(3.2), Float(3.0)),
            (Float(-3.2), Float(-3.0)),
            (Float(-3.7), Float(-3.0)),
            (Float(0.0), Float(0.0)),
        ])
    func `float trunc rounds toward zero`(value: Float, expected: Float) {
        #expect(IEEE_754.Rounding.trunc(value) == expected)
        #expect(value.ieee754.trunc == expected)
    }

    @Test
    func `float trunc handles special values`() {
        #expect(IEEE_754.Rounding.trunc(Float.infinity) == Float.infinity)
        #expect(IEEE_754.Rounding.trunc(-Float.infinity) == -Float.infinity)
        #expect(IEEE_754.Rounding.trunc(Float.nan).isNaN)
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (3.4, 3.0),
            (3.5, 4.0),
            (3.6, 4.0),
            (4.5, 5.0),
            (5.5, 6.0),
            (-3.4, -3.0),
            (-3.5, -4.0),
            (-3.6, -4.0),
            (-4.5, -5.0),
            (-5.5, -6.0),
            (0.5, 1.0),
            (-0.5, -1.0),
            (2.5, 3.0),
            (1.5, 2.0),
        ])
    func `roundAwayFromZero rounds to nearest (ties away from zero)`(
        value: Double,
        expected: Double
    ) {
        #expect(IEEE_754.Rounding.roundAwayFromZero(value) == expected)
        #expect(value.ieee754.roundAwayFromZero == expected)
    }

    @Test
    func `roundAwayFromZero handles special values`() {
        #expect(IEEE_754.Rounding.roundAwayFromZero(Double.infinity) == Double.infinity)
        #expect(IEEE_754.Rounding.roundAwayFromZero(-Double.infinity) == -Double.infinity)
        #expect(IEEE_754.Rounding.roundAwayFromZero(Double.nan).isNaN)
        #expect(IEEE_754.Rounding.roundAwayFromZero(0.0) == 0.0)
        #expect(IEEE_754.Rounding.roundAwayFromZero(-0.0) == -0.0)
    }

    @Test
    func `roundAwayFromZero differs from round on ties`() {

        let tieValues = [0.5, 1.5, 2.5, 3.5, 4.5, -0.5, -1.5, -2.5, -3.5, -4.5]
        for value in tieValues {
            let awayResult = IEEE_754.Rounding.roundAwayFromZero(value)
            let evenResult = IEEE_754.Rounding.round(value)

            #expect(awayResult.truncatingRemainder(dividingBy: 1.0) == 0.0)
            #expect(evenResult.truncatingRemainder(dividingBy: 1.0) == 0.0)

            if value > 0 {
                #expect(awayResult >= value, "Positive tie should round up")
            } else if value < 0 {
                #expect(awayResult <= value, "Negative tie should round down")
            }
        }
    }
}

extension IEEE_754.Rounding.Test {
    @Test(
        arguments: [
            (Float(3.4), Float(3.0)),
            (Float(3.5), Float(4.0)),
            (Float(3.6), Float(4.0)),
            (Float(4.5), Float(5.0)),
            (Float(-3.5), Float(-4.0)),
            (Float(0.5), Float(1.0)),
            (Float(-0.5), Float(-1.0)),
        ])
    func `float roundAwayFromZero rounds to nearest (ties away from zero)`(
        value: Float,
        expected: Float
    ) {
        #expect(IEEE_754.Rounding.roundAwayFromZero(value) == expected)
        #expect(value.ieee754.roundAwayFromZero == expected)
    }

    @Test
    func `float roundAwayFromZero handles special values`() {
        #expect(IEEE_754.Rounding.roundAwayFromZero(Float.infinity) == Float.infinity)
        #expect(IEEE_754.Rounding.roundAwayFromZero(-Float.infinity) == -Float.infinity)
        #expect(IEEE_754.Rounding.roundAwayFromZero(Float.nan).isNaN)
    }
}

extension IEEE_754.Rounding.Test {
    @Test
    func `large values are handled correctly`() {
        let large = 1_000_000_000.7
        #expect(IEEE_754.Rounding.floor(large) == 1_000_000_000.0)
        #expect(IEEE_754.Rounding.ceil(large) == 1_000_000_001.0)
        #expect(IEEE_754.Rounding.trunc(large) == 1_000_000_000.0)
    }

    @Test
    func `very small values are handled correctly`() {
        let small = 0.0000001
        #expect(IEEE_754.Rounding.floor(small) == 0.0)
        #expect(IEEE_754.Rounding.ceil(small) == 1.0)
        #expect(IEEE_754.Rounding.round(small) == 0.0)
        #expect(IEEE_754.Rounding.trunc(small) == 0.0)
    }

    @Test
    func `subnormal values are handled correctly`() {
        let subnormal = Double.leastNonzeroMagnitude
        #expect(IEEE_754.Rounding.floor(subnormal) == 0.0)
        #expect(IEEE_754.Rounding.ceil(subnormal) == 1.0)
        #expect(IEEE_754.Rounding.round(subnormal) == 0.0)
        #expect(IEEE_754.Rounding.trunc(subnormal) == 0.0)
    }

    @Test
    func `maximum finite values are handled correctly`() {
        let max = Double.greatestFiniteMagnitude
        #expect(IEEE_754.Rounding.floor(max) == max)
        #expect(IEEE_754.Rounding.ceil(max) == max)
        #expect(IEEE_754.Rounding.round(max) == max)
        #expect(IEEE_754.Rounding.trunc(max) == max)
    }
}

extension IEEE_754.Rounding.Test {
    @Test
    func `floor preserves sign of zero`() {
        let positiveZero = IEEE_754.Rounding.floor(0.0)
        let negativeZero = IEEE_754.Rounding.floor(-0.0)
        #expect(positiveZero == 0.0)
        #expect(negativeZero == -0.0)
        #expect(positiveZero.sign == .plus)
        #expect(negativeZero.sign == .minus)
    }

    @Test
    func `ceil preserves sign of zero`() {
        let positiveZero = IEEE_754.Rounding.ceil(0.0)
        let negativeZero = IEEE_754.Rounding.ceil(-0.0)
        #expect(positiveZero == 0.0)
        #expect(negativeZero == -0.0)
        #expect(positiveZero.sign == .plus)
        #expect(negativeZero.sign == .minus)
    }

    @Test
    func `round preserves sign of zero`() {
        let positiveZero = IEEE_754.Rounding.round(0.0)
        let negativeZero = IEEE_754.Rounding.round(-0.0)
        #expect(positiveZero == 0.0)
        #expect(negativeZero == -0.0)
        #expect(positiveZero.sign == .plus)
        #expect(negativeZero.sign == .minus)
    }

    @Test
    func `trunc preserves sign of zero`() {
        let positiveZero = IEEE_754.Rounding.trunc(0.0)
        let negativeZero = IEEE_754.Rounding.trunc(-0.0)
        #expect(positiveZero == 0.0)
        #expect(negativeZero == -0.0)
        #expect(positiveZero.sign == .plus)
        #expect(negativeZero.sign == .minus)
    }
}

extension IEEE_754.Rounding.Test {
    @Test
    func `apply with Direction enum - towardInfinity(.negative) is floor`() {
        #expect(IEEE_754.Rounding.apply(3.7, direction: .towardInfinity(.negative)) == 3.0)
        #expect(IEEE_754.Rounding.apply(-3.7, direction: .towardInfinity(.negative)) == -4.0)
        #expect(IEEE_754.Rounding.apply(Float(3.7), direction: .towardInfinity(.negative)) == 3.0)
    }

    @Test
    func `apply with Direction enum - towardInfinity(.positive) is ceil`() {
        #expect(IEEE_754.Rounding.apply(3.2, direction: .towardInfinity(.positive)) == 4.0)
        #expect(IEEE_754.Rounding.apply(-3.2, direction: .towardInfinity(.positive)) == -3.0)
        #expect(IEEE_754.Rounding.apply(Float(3.2), direction: .towardInfinity(.positive)) == 4.0)
    }

    @Test
    func `apply with Direction enum - towardZero is trunc`() {
        #expect(IEEE_754.Rounding.apply(3.7, direction: .towardZero) == 3.0)
        #expect(IEEE_754.Rounding.apply(-3.7, direction: .towardZero) == -3.0)
        #expect(IEEE_754.Rounding.apply(Float(3.7), direction: .towardZero) == 3.0)
    }

    @Test
    func `apply with Direction enum - toNearest(.toEven) is round`() {
        #expect(IEEE_754.Rounding.apply(3.5, direction: .toNearest(.toEven)) == 4.0)
        #expect(IEEE_754.Rounding.apply(4.5, direction: .toNearest(.toEven)) == 4.0)
        #expect(IEEE_754.Rounding.apply(Float(3.5), direction: .toNearest(.toEven)) == 4.0)
    }

    @Test
    func `apply with Direction enum - toNearest(.awayFromZero) is roundAwayFromZero`() {
        #expect(IEEE_754.Rounding.apply(3.5, direction: .toNearest(.awayFromZero)) == 4.0)
        #expect(IEEE_754.Rounding.apply(4.5, direction: .toNearest(.awayFromZero)) == 5.0)
        #expect(IEEE_754.Rounding.apply(Float(3.5), direction: .toNearest(.awayFromZero)) == 4.0)
    }

    @Test
    func `Direction enum pattern matching works correctly`() {
        let directions: [IEEE_754.Rounding.Direction] = [
            .towardInfinity(.negative),
            .towardInfinity(.positive),
            .towardZero,
            .toNearest(.toEven),
            .toNearest(.awayFromZero),
        ]

        for direction in directions {
            let result = IEEE_754.Rounding.apply(3.5, direction: direction)
            #expect(result.isFinite)

            switch direction {
            case .towardInfinity(.negative):
                #expect(result == 3.0)

            case .towardInfinity(.positive):
                #expect(result == 4.0)

            case .towardZero:
                #expect(result == 3.0)

            case .toNearest(.toEven):
                #expect(result == 4.0)

            case .toNearest(.awayFromZero):
                #expect(result == 4.0)
            }
        }
    }
}
