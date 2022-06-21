//
//  SwiftShareTests.swift
//  SwiftShareTests
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import XCTest
@testable import SwiftShare

class SwiftShareTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testXOR() {
        XCTAssertEqual(true ^^ true, false)
        XCTAssertEqual(true ^^ false, true)
        XCTAssertEqual(false ^^ true, true)
        XCTAssertEqual(false ^^ false, false)
    }

}
