// Copyright (c) 2015 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import MyNewApp

class LicenseWriterTests: XCTestCase {

    let userDefaultsDouble: TestUserDefaults = TestUserDefaults()
    
    override func setUp() {
        
        super.setUp()
        
        // No need to set the double on licenseProvider because
        // its property is lazily loaded during test cases later.
        MyNewApp.UserDefaults.sharedInstance = MyNewApp.UserDefaults(userDefaults: userDefaultsDouble)
    }
    
    override func tearDown() {
        
        MyNewApp.UserDefaults.resetSharedInstance()
        
        super.tearDown()
    }
    
    
    // MARK: Storing
    
    func testStoring_DelegatesToUserDefaults() {
        
        // Given
        let writer = LicenseWriter()
        let licenseCode = "a license code"
        let name = "a name"
        
        // When
        writer.storeLicenseCode(licenseCode, forName: name)
        
        // Then
        let changedDefaults = userDefaultsDouble.didSetValuesForKeys
        XCTAssert(hasValue(changedDefaults))
        
        if let changedDefaults = changedDefaults {
            
            XCTAssert(changedDefaults[License.UserDefaultsKeys.Name.rawValue] == name)
            XCTAssert(changedDefaults[License.UserDefaultsKeys.LicenseCode.rawValue] == licenseCode)
        }
    }


    // MARK: -
    
    class TestUserDefaults: NullUserDefaults {
        
        var didSetValuesForKeys: [String : String]?
        override func setValue(_ value: Any?, forKey key: String) {
            
            if !hasValue(didSetValuesForKeys) {
                didSetValuesForKeys = [String : String]()
            }
            
            didSetValuesForKeys![key] = value as? String
        }
    }
}
