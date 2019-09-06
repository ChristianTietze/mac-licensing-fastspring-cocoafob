// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import MyNewApp

class ExistingLicenseViewControllerTests: XCTestCase {

    var controller: ExistingLicenseViewController!
    
    override func setUp() {
        
        super.setUp()
        
        let windowController = LicenseWindowController()
        loadWindow(windowController)
        
        controller = windowController.existingLicenseViewController
    }
    

    // MARK: Nib Loading
    
    func testLicenseeTextField_IsConnected() {
        
        XCTAssertNotNil(controller.licenseeTextField)
    }
    
    func testLicenseCodeTextField_IsConnected() {
        
        XCTAssertNotNil(controller.licenseCodeTextField)
    }
    
    func testRegisterButton_IsConnected() {
        
        XCTAssertNotNil(controller.registerButton)
    }

    func testRegisterButton_IsWiredToAction() {

        XCTAssert(button(controller.registerButton, isWiredTo: controller, using: #selector(ExistingLicenseViewController.register(_:))))
    }
    
    
    // MARK: Registering
    
    func testRegistering_DelegatesToEventHandler() {
        
        // Given
        let eventHandlerDouble = TestEventHandler()
        controller.eventHandler = eventHandlerDouble
        
        let name = "a name"
        let licenseCode = "123-key"
        controller.licenseeTextField?.stringValue = name
        controller.licenseCodeTextField?.stringValue = licenseCode
        
        // When
        controller.register(self)
        
        // Then
        let registerParams = eventHandlerDouble.didRegisterWith
        XCTAssertNotNil(registerParams)
        if let registerParams = registerParams {
            XCTAssertEqual(registerParams.name, name)
            XCTAssertEqual(registerParams.licenseCode, licenseCode)
        }
    }
    
    
    // MARK: Displaying licenses

    func testDisplayEmptyForm_EmptiesLicenseeNameTextField() {
        
        controller.licenseeTextField.stringValue = "something"
        
        controller.displayEmptyForm()
        
        XCTAssertEqual(controller.licenseeTextField.stringValue, "")
    }
    
    func testDisplayEmptyForm_EmptiesLicenseCodeTextField() {
        
        controller.licenseCodeTextField.stringValue = "something"
        
        controller.displayEmptyForm()
        
        XCTAssertEqual(controller.licenseCodeTextField.stringValue, "")
    }
    
    func testDisplayLicense_FillsLicenseeNameTextField() {
        
        let license = License(name: "a name", licenseCode: "a code")
        controller.licenseeTextField.stringValue = ""
        
        controller.display(license: license)
        
        XCTAssertEqual(controller.licenseeTextField.stringValue, "a name")
    }
    
    func testDisplayLicense_FillsLicenseCodeTextField() {
        
        let license = License(name: "alicenseCodeme", licenseCode: "a code")
        controller.licenseCodeTextField.stringValue = ""
        
        controller.display(license: license)
        
        XCTAssertEqual(controller.licenseCodeTextField.stringValue, "a code")
    }
    
    
    // MARK: - 
    
    class TestEventHandler: HandlesRegistering {
        var didRegisterWith: (name: String, licenseCode: String)?
        func register(name: String, licenseCode: String) {
            didRegisterWith = (name, licenseCode)
        }
    }
}
