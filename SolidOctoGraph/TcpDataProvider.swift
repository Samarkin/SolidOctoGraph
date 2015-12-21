import Foundation

private let newLine = "\r\n".dataUsingEncoding(NSASCIIStringEncoding)

class TcpDataProvider: NSObject {
    private var socket: GCDAsyncSocket!
    var connected: (() -> Void)?
    var delegate: (String -> ())?

    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }

    func connect(host: String, port: Int) {
        try! socket.connectToHost(host, onPort: UInt16(port))
        socket.readDataToData(newLine, withTimeout: -1, tag: 1)
    }

    func socket(sender: GCDAsyncSocket, didConnectToHost host: NSString, port: UInt16) {
        connected?()
    }

    func socket(sender: GCDAsyncSocket, didReadData data: NSData, withTag tag:Int) {
        let s = String(data: data, encoding: NSASCIIStringEncoding)!
        self.delegate?(s)
        socket.readDataToData(newLine, withTimeout: -1, tag: 1)
    }
}