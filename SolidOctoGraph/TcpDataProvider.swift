protocol TcpDataProvider {
    var connected: (() -> Void)? { get set}
    var delegate: ([Double] -> ())? { get set }
    func connect(host: String, port: Int)
}