extension IEEE_754 {

    public struct Outcome<Value: Sendable>: Sendable {

        public let value: Value

        public let status: Status

        @inlinable
        public init(value: Value, status: Status = .none) {
            self.value = value
            self.status = status
        }
    }
}

extension IEEE_754.Outcome {

    @inlinable
    public static func clean(_ value: Value) -> Self {
        Self(value: value, status: .none)
    }
}

extension IEEE_754.Outcome {

    @inlinable
    public var exceptions: Bool {
        !status.isEmpty
    }

    @inlinable
    public var clean: Bool {
        status.isEmpty
    }
}

extension IEEE_754.Outcome: Equatable where Value: Equatable {}

extension IEEE_754.Outcome: Hashable where Value: Hashable {}
