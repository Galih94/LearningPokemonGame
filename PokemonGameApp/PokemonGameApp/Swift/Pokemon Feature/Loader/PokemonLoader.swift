//
//  PokemonLoader.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation

public protocol PokemonLoader {
    typealias Result = Swift.Result<[Pokemon], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
