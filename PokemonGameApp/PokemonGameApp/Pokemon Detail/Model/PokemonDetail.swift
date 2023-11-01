//
//  PokemonDetail.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 27/10/23.
//

import Foundation

public struct PokemonDetail {
    public let name: String
    public let imageURL: URL
    public let moves: [String]
    public let types: [String]
    
    public init(name: String, imageURL: URL, moves: [String], types: [String]) {
        self.name = name
        self.imageURL = imageURL
        self.moves = moves
        self.types = types
    }
}
