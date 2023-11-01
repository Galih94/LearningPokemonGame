//
//  XCTestsCase+Ext.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 27/10/23.
//

import XCTest
import PokemonGameApp

extension XCTestCase {
    
    func makePokemonDetail() -> PokemonDetail {
        return PokemonDetail(
            name: "weedle",
            imageURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/13.png")!,
            moves: ["poison-sting", "string-shot", "bug-bite", "electroweb"],
            types: ["bug", "poison"])
    }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have beed deallocated, potential memory leak", file: file, line: line)
        }
    }
    
}
