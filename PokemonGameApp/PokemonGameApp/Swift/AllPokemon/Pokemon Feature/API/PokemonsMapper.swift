//
//  PokemonsMapper.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation

final class PokemonsMapper {
    
    private static var OK_200: Int { return 200 }
    private struct Results: Decodable {
        let items: [RemotePokemon]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemotePokemon] {
        guard let results = try? JSONDecoder().decode(Results.self, from: data),
                response.statusCode == OK_200 else {
            throw RemotePokemonLoader.Error.invalidData
        }
        
        return results.items
    }
}
