import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textField: NSTextField!
    @IBOutlet var graphView: OctoGraphView!

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
    }

}

