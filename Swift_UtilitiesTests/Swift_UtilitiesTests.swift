//
//  Swift_UtilitiesTests.swift
//  Swift_UtilitiesTests
//
//  Created by tridiak on 12/06/22.
//  Copyright © 2022 tridiak. All rights reserved.
//

import XCTest

class Swift_UtilitiesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringStuff() throws {
		
		XCTAssertEqual("EFGH", "ABCDEFGH".RemoveFrom(set: CharacterSet(charactersIn: "ABCD")))
		XCTAssertEqual("EFGH", "ABCDEFGH".RemoveFrom(set: "ABCD"))
		var s = "ABCDEFGH"
		s.RemoveFromM(set: CharacterSet(charactersIn: "ABCD"))
		XCTAssert(s, "EFGH")
		s = "ABCDEFGH"
		s.RemoveFromM(set: "ABCD")
		XCTAssert(s, "EFGH")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
	
	
}
