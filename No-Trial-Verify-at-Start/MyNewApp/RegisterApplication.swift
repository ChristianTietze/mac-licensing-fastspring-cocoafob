// Copyright (c) 2015 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

open class RegisterApplication: HandlesRegistering {
    
    let licenseVerifier: LicenseVerifier
    let licenseWriter: LicenseWriter
    let changeBroadcaster: LicenseChangeBroadcaster
    
    public convenience init() {
        
        self.init(licenseVerifier: LicenseVerifier(), licenseWriter: LicenseWriter(), changeBroadcaster: LicenseChangeBroadcaster())
    }
    
    public init(licenseVerifier: LicenseVerifier, licenseWriter: LicenseWriter, changeBroadcaster: LicenseChangeBroadcaster) {
        
        self.licenseVerifier = licenseVerifier
        self.licenseWriter = licenseWriter
        self.changeBroadcaster = changeBroadcaster
    }
    
    open func register(_ name: String, licenseCode: String) {
        
        if !licenseVerifier.licenseCodeIsValid(licenseCode, forName: name) {
            
            displayLicenseCodeError()
            return
        }
        
        let licenseInformation = LicenseInformation.registered(License(name: name, licenseCode: licenseCode))
        
        licenseWriter.storeLicenseCode(licenseCode, forName: name)
        changeBroadcaster.broadcast(licenseInformation)
    }
    
    func displayLicenseCodeError() {
        
        Alerts.invalidLicenseCodeAlert()?.runModal()
    }
}
