//
//  PokemonsMapper.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation

final class PokemonsMapper {
    
    private static var OK_200: Int { return 200 }
    private struct Roots: Decodable {
        let results: [RemotePokemon]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemotePokemon] {
        guard let roots = try? JSONDecoder().decode(Roots.self, from: data),
                response.statusCode == OK_200 else {
            throw RemotePokemonLoader.Error.invalidData
        }
        
        return roots.results
    }
}
