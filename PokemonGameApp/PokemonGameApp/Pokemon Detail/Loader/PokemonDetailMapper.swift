//
//  PokemonDetailMapper.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 27/10/23.
//

import Foundation

enum PokemonDetailMapper {
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> PokemonDetail {
        guard response.statusCode == OK_200,
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RemotePokemonDetailLoader.Error.invalidData
        }
            
        let name = dict["name"] as? String ?? ""
        
        
        
        guard let sprite = dict["sprites"] as? [String: Any],
                let imageUrlString = sprite["front_default"] as? String,
                let imageURL = URL(string: imageUrlString) else {
            throw RemotePokemonDetailLoader.Error.notFoundImageURL
        }
        
        let moves = dict["moves"] as? [[String: Any]] ?? []
        let moveNames = moves.map { moveObj in
            let move = moveObj["move"] as? [String: Any]
            let name = move?["name"] as? String ?? ""
            return name
        }
        
        let types = dict["types"] as? [[String: Any]] ?? []
        let typeNames = types.map { typeObj in
            let typePokemon = typeObj["type"] as? [String: Any]
            let name = typePokemon?["name"] as? String ?? ""
            return name
        }
        
        return PokemonDetail(name: name, imageURL: imageURL, moves: moveNames, types: typeNames)
    }
}
