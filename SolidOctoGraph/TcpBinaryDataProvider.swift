import Foundation

enum DataType {
    case Int8
    case UInt8
    case Int16
    case UInt16
}

class DataDescription {
    let types: [DataType]
    let length: UInt
    init(types: [DataType]) {
        self.types = types
        self.length = types.map {
            switch $0 {
            case .Int8, .UInt8:
                return 1
            case .Int16, .UInt16:
                return 2
            }
        }.reduce(0, combine: +)
    }
    func extractArrayFromData(data: NSData) -> [Double] {
        var cur = 0
        var result: [Double] = []
        for type in types {
            switch(type) {
            case .Int8:
                var x: Int8 = 0
                data.getBytes(&x, range: NSRange(location: cur, length: 1))
                cur += 1
                result.append(Double(x))
            case .UInt8:
                var x: UInt8 = 0
                data.getBytes(&x, range: NSRange(location: cur, length: 1))
                cur += 1
                result.append(Double(x))
            case .Int16:
                var x: Int16 = 0
                data.getBytes(&x, range: NSRange(location: cur, length: 2))
                cur += 2
                result.append(Double(x))
            case .UInt16:
                var x: UInt16 = 0
                data.getBytes(&x, range: NSRange(location: cur, length: 2))
                cur += 2
                result.append(Double(x))
            }

        }
        return result
    }
}

class TcpBinaryDataProvider: NSObject, TcpDataProvider {
    private var socket: GCDAsyncSocket!
    var connected: (() -> Void)?
    var delegate: ([Double] -> ())?
    var dataDescription: DataDescription

    init(types: [DataType]) {
        dataDescription =  DataDescription(types: types)
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }

    func connect(host: String, port: Int) {
        try! socket.connectToHost(host, onPort: UInt16(port))
        socket.readDataToLength(dataDescription.length, withTimeout: -1, tag: 1)
    }

    func socket(sender: GCDAsyncSocket, didConnectToHost host: NSString, port: UInt16) {
        connected?()
    }

    func socket(sender: GCDAsyncSocket, didReadData data: NSData, withTag tag:Int) {
        self.delegate?(dataDescription.extractArrayFromData(data))
        socket.readDataToLength(dataDescription.length, withTimeout: -1, tag: 1)
    }
}