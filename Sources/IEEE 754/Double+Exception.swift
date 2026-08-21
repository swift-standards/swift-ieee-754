extension Double {

    public enum Exception {}

    public static var exception: Exception.Type { Exception.self }
}

extension Double.Exception {

    public typealias State = Float.Exception.State
}

extension Double.Exception {

    @inlinable
    public static func test() -> State {
        Float.exception.test()
    }

    @inlinable
    public static func clear() {
        Float.exception.clear()
    }
}
