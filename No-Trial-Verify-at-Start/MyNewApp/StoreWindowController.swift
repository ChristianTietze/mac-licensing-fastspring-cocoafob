// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa

public class OrderConfirmationView: NSView {
    
    @IBOutlet public var licenseCodeTextField: NSTextField!
    
    public func display(licenseCode: String) {
        
        licenseCodeTextField.stringValue = licenseCode
    }
}

public class StoreWindowController: NSWindowController {

    static let nibName = "StoreWindowController"
    
    public convenience init() {
        
        self.init(windowNibName: StoreWindowController.nibName)
    }
    
    @IBOutlet public var webView: WebView!
    @IBOutlet public var orderConfirmationView: OrderConfirmationView!
    
    @IBOutlet public var backButton: NSButton!
    @IBOutlet public var forwardButton: NSButton!
    @IBOutlet public var reloadButton: NSButton!
    
    @objc public var storeController: StoreController!
    
    public var storeDelegate: StoreDelegate? {
        get {
            return storeController.storeDelegate
        }
        
        set {
            storeController.storeDelegate = newValue
        }
    }
    
    public override func awakeFromNib() {
        
        storeController.set(webView: webView)
        storeController.loadStore()
        storeController.orderConfirmationView = orderConfirmationView
    }
    
    @IBAction public func reloadStore(_ sender: AnyObject) {
        
        storeController.loadStore()
    }
}
