//
//  RemotePokemonLoader.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation
import PokemonGameNetwork


public final class RemotePokemonLoader: PokemonLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = PokemonLoader.Result
    
    public init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void ) {
        client.request(from: URLRequest(url: url)) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemotePokemonLoader.map(data: data, response: response))
            case .failure( _):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try PokemonsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemotePokemon {
    func toModels() -> [Pokemon] {
        return map { pokemon in
            let urlString = pokemon.url.absoluteString
            var replacedURL = urlString.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon/", with: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/")
            replacedURL.removeLast()
            let spriteURL = replacedURL + ".png"
            return Pokemon(name: pokemon.name, url: URL(string: spriteURL)! )
        }
    }
}
