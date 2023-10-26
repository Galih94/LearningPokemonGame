//
//  RemotePokemon.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation

struct RemotePokemon: Decodable {
    let name: String
    let url: URL
}
