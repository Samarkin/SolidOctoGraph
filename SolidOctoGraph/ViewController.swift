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
        dataProvider = TcpTextDataProvider()
        let a = textField.stringValue.characters.split(":").map(String.init)
        dataProvider.connected = { [weak self] in
            self?.view.window!.title = "Graph"
        }
        dataProvider.delegate = { [weak self] in self?.graphView.push($0) }
        dataProvider.connect(a[0], port: Int(a[1])!)
        self.view.window!.title = "Connecting to \(a)..."
    }

}

