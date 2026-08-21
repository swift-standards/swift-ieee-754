public import Dependency_Primitives
public import Synchronization

extension IEEE_754 {

    public enum Exceptions {}
}

extension IEEE_754.Exceptions {

    public enum Flag: Sendable, Equatable, CaseIterable {

        case invalid

        case divisionByZero

        case overflow

        case underflow

        case inexact
    }
}

extension IEEE_754.Exceptions.Flag: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: return "invalid"
        case .divisionByZero: return "divisionByZero"
        case .overflow: return "overflow"
        case .underflow: return "underflow"
        case .inexact: return "inexact"
        }
    }
}

extension IEEE_754.Exceptions {

    @usableFromInline
    final class ExceptionState: @unchecked Sendable {
        @usableFromInline
        let state: Mutex<Flags> = Mutex(Flags())

        @usableFromInline
        init() {}
    }

    @usableFromInline
    static var state: ExceptionState {
        Dependency.Scope.current[ExceptionState.self]
    }
}

extension IEEE_754.Exceptions.ExceptionState {
    @usableFromInline
    struct Flags {
        var invalid: Bool = false
        var divisionByZero: Bool = false
        var overflow: Bool = false
        var underflow: Bool = false
        var inexact: Bool = false
    }

    @usableFromInline
    static let _global = IEEE_754.Exceptions.ExceptionState()
}

extension IEEE_754.Exceptions.ExceptionState: Dependency.Key {
    @usableFromInline
    typealias Value = IEEE_754.Exceptions.ExceptionState

    @usableFromInline
    static var liveValue: IEEE_754.Exceptions.ExceptionState { _global }

    @usableFromInline
    static var testValue: IEEE_754.Exceptions.ExceptionState { .init() }
}

extension IEEE_754.Exceptions.ExceptionState {
    @usableFromInline
    func set(_ flag: IEEE_754.Exceptions.Flag) {
        state.withLock { flags in
            switch flag {
            case .invalid: flags.invalid = true
            case .divisionByZero: flags.divisionByZero = true
            case .overflow: flags.overflow = true
            case .underflow: flags.underflow = true
            case .inexact: flags.inexact = true
            }
        }
    }

    @usableFromInline
    func clear(_ flag: IEEE_754.Exceptions.Flag) {
        state.withLock { flags in
            switch flag {
            case .invalid: flags.invalid = false
            case .divisionByZero: flags.divisionByZero = false
            case .overflow: flags.overflow = false
            case .underflow: flags.underflow = false
            case .inexact: flags.inexact = false
            }
        }
    }

    @usableFromInline
    func get(_ flag: IEEE_754.Exceptions.Flag) -> Bool {
        state.withLock { flags in
            switch flag {
            case .invalid: return flags.invalid
            case .divisionByZero: return flags.divisionByZero
            case .overflow: return flags.overflow
            case .underflow: return flags.underflow
            case .inexact: return flags.inexact
            }
        }
    }

    @usableFromInline
    func clearAll() {
        state.withLock { flags in
            flags.invalid = false
            flags.divisionByZero = false
            flags.overflow = false
            flags.underflow = false
            flags.inexact = false
        }
    }
}

extension IEEE_754.Exceptions {

    public static func raise(_ flag: Flag) {
        state.set(flag)
    }

    public static func test(_ flag: Flag) -> Bool {
        state.get(flag)
    }

    public static func clear(_ flag: Flag) {
        state.clear(flag)
    }

    public static func clear() {
        state.clearAll()
    }

}

extension IEEE_754.Exceptions {

    @inlinable
    public static var invalidOperation: Bool {
        test(.invalid)
    }

    @inlinable
    public static var divisionByZero: Bool {
        test(.divisionByZero)
    }

    @inlinable
    public static var overflow: Bool {
        test(.overflow)
    }

    @inlinable
    public static var underflow: Bool {
        test(.underflow)
    }

    @inlinable
    public static var inexact: Bool {
        test(.inexact)
    }
}
