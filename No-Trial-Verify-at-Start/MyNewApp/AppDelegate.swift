// Copyright (c) 2015 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa

let isRunningTests = NSClassFromString("XCTestCase") != nil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    lazy var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    var licenseProvider = LicenseProvider()
    lazy var licenseInfoProvider: LicenseInformationProvider = LicenseInformationProvider(licenseProvider: self.licenseProvider)
    
    lazy var licenseWindowController: LicenseWindowController = LicenseWindowController()
    
    // Use Cases / Services
    var purchaseLicense: PurchaseLicense!
    var registerApplication = RegisterApplication()
    
    
    // MARK: Startup
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        if isRunningTests {
            return
        }
        
        registerForURLScheme()
        observeLicenseChanges()
        prepareLicenseWindowController()
        launchAppOrShowLicenseWindow()
    }
    
    func registerForURLScheme() {
        
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: Selector("handleGetUrlEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func handleGetUrlEvent(event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        
        if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue, url = NSURL(string: urlString) {
            
            // If you support multiple actions, here'd be the place to 
            // delegate to a router object instead.
            
            URLQueryRegistration(registrationHandler: registerApplication)
                .registerFromURL(url)
        }
    }

    func observeLicenseChanges() {
        
        notificationCenter.addObserver(self, selector: Selector("licenseDidChange:"), name: Events.LicenseChanged.rawValue, object: nil)
    }
    
    func prepareLicenseWindowController() {
        
        let storeInfo = StoreInfoReader.defaultStoreInfo()
        assert(hasValue(storeInfo), "Provide store details in FastSpringCredentials")
        
        let store = Store(storeInfo: storeInfo!)
        purchaseLicense = PurchaseLicense(store: store, registerApplication: registerApplication)

        store.storeDelegate = purchaseLicense
        licenseWindowController.purchasingEventHandler = purchaseLicense
    }
    
    var currentLicenseInformation: LicenseInformation {
        
        return licenseInfoProvider.currentLicenseInformation
    }
    
    func launchAppOrShowLicenseWindow() {
        
        switch currentLicenseInformation {
        case .Unregistered:
            if licenseIsInvalid() {
                displayInvalidLicenseAlert()
            }
            
            showRegisterApp()
        case let .Registered(license):
            
            unlockApp()
        }
    }
    
    func licenseIsInvalid() -> Bool {
        
        if let license = licenseProvider.currentLicense {
            
            return !LicenseVerifier().licenseCodeIsValid(license.licenseCode, forName: license.name)
        }
        
        return false
    }
    
    func displayInvalidLicenseAlert() {
        
        Alerts.invalidLicenseCodeAlert()?.runModal()
    }
    
    
    // MARK: Show windows
    
    func showRegisterApp() {
        
        licenseWindowController.showWindow(self)
        licenseWindowController.registrationEventHandler = registerApplication
        licenseWindowController.displayLicenseInformation(currentLicenseInformation)
    }
    
    func unlockApp() {
        
        licenseWindowController.close()
        window.makeKeyAndOrderFront(self)
    }

    
    // MARK: License changes
    
    func licenseDidChange(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, licenseInformation = LicenseInformation.fromUserInfo(userInfo) {
            
            switch licenseInformation {
            case .Registered(_):
                displayThankYouAlert()
                unlockApp()
                
            case .Unregistered:
                // If you support un-registering, handle it here
                return
            }
        }
    }
    
    func displayThankYouAlert() {
        
        Alerts.thankYouAlert()?.runModal()
    }
    
    
    // MARK: UI Interactions
    
    // NOTE: Don't cram too much into your AppDelegate. Extract the window
    // from the MainMenu Nib instead and provide a real `NSWindowController`.
    
    @IBAction func reviewLicense(sender: AnyObject) {
    
        showRegisterApp()
    }
}
