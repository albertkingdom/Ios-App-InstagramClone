//
//  InstagramCloneTests.swift
//  InstagramCloneTests
//
//  Created by Albert Lin on 2022/4/23.
//

import XCTest
@testable import InstagramClone

class InstagramCloneTests: XCTestCase {
    var sut: ValidationService!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = ValidationService()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testTwoPasswordNotMatch() {
        let password1 = "123"
        let password2 = "234"
        
        let result = sut.isSignUpPasswordValid(password1: password1, password2: password2)
        
        XCTAssert(result == SignUpPasswordValidationResult.PasswordNotMatch)
    }
    
    func testPasswordLengthNotEnough() {
        let password1 = "12345"
        let password2 = "12345"
        
        let result = sut.isSignUpPasswordValid(password1: password1, password2: password2)
      
        XCTAssert(result == SignUpPasswordValidationResult.PasswordLengthNotEnough)
    }
    
    func testPasswordIsValid() {
        let password1 = "123456"
        let password2 = "123456"
        
        let result = sut.isSignUpPasswordValid(password1: password1, password2: password2)
       
        XCTAssert(result == SignUpPasswordValidationResult.PasswordValid)
    }

}
