import Foundation

private let newLine = "\r\n".dataUsingEncoding(NSASCIIStringEncoding)

class TcpTextDataProvider: NSObject, TcpDataProvider {
    private var socket: GCDAsyncSocket!
    var connected: (() -> Void)?
    var delegate: ([Double] -> ())?

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

    private func callDelegate(s: String) {
        guard let delegate = self.delegate else {
            return
        }
        var z = [Double]()
        for x in s.characters.dropLast(2).split(" ", maxSplit: 3, allowEmptySlices: false) {
            if let d = Double(String(x)) {
                z.append(d)
            }
            else {
                return
            }
        }
        delegate(z)
    }

    func socket(sender: GCDAsyncSocket, didReadData data: NSData, withTag tag:Int) {
        let s = String(data: data, encoding: NSASCIIStringEncoding)!
        callDelegate(s)
        socket.readDataToData(newLine, withTimeout: -1, tag: 1)
    }
}