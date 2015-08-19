import Cocoa

public class StoreWindowController: NSWindowController {

    static let NibName = "StoreWindowController"
    
    public convenience init() {
        
        self.init(windowNibName: StoreWindowController.NibName)
    }
    
    @IBOutlet public var webView: WebView!
    
    @IBOutlet public var backButton: NSButton!
    @IBOutlet public var forwardButton: NSButton!
    @IBOutlet public var reloadButton: NSButton!
    
    public var storeController: StoreController!
    
    public var storeDelegate: StoreDelegate? {
        get {
            return storeController.storeDelegate
        }
        
        set {
            storeController.storeDelegate = newValue
        }
    }
    
    public override func awakeFromNib() {
        
        storeController.setWebView(webView)
        storeController.loadStore()
    }
    
    @IBAction public func reloadStore(sender: AnyObject) {
        
        storeController.loadStore()
    }
}
