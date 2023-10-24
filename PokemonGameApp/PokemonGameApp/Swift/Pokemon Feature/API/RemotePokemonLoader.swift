//
//  RemotePokemonLoader.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation
import PokemonGameNetwork

struct RemotePokemon: Decodable {
    let name: String
    let url: URL
}

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
        return map {
            Pokemon(name: $0.name, url: $0.url)
        }
    }
}
