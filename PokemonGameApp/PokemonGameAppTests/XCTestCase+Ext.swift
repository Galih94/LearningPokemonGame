//
//  XCTestCase+Ext.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 24/10/23.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have beed deallocated, potential memory leak", file: file, line: line)
        }
    }
    
}
