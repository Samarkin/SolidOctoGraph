import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textField: NSTextField!
    @IBOutlet var graphView: OctoGraphView!
    @IBOutlet var connectButton: NSButton!

    private var dataProvider: TcpDataProvider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func connectClick(sender: AnyObject) {
        connectButton.enabled = false
        dataProvider = TcpDataProvider()
        let a = textField.stringValue.characters.split(":").map(String.init)
        dataProvider.connected = {
            self.view.window!.title = "Graph"
        }
        dataProvider.delegate = { (s: String) in
            var z = [Double]()
            for x in s.characters.dropLast(2).split(" ", maxSplit: 3, allowEmptySlices: false) {
                if let d = Double(String(x)) {
                    z.append(d)
                }
                else {
                    return
                }
            }
            self.graphView.push(z)
        }
        dataProvider.connect(a[0], port: Int(a[1])!)
        self.view.window!.title = "Connecting to \(a)..."
    }

}

