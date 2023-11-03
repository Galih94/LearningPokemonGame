//
//  PokemonDetailLoader.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 27/10/23.
//

import Foundation
import PokemonGameNetwork
import PokemonGameCommon

public protocol PokemonDetailLoader {
    typealias Result = Swift.Result<PokemonDetail, Error>
    
    func load(name: String, completion: @escaping (Result) -> Void)
}

public final class RemotePokemonDetailLoader: PokemonDetailLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case notFoundImageURL
    }
    
    public typealias Result = PokemonDetailLoader.Result
    
    public init (url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(name: String, completion: @escaping (Result) -> Void) {
        client.request(from: URLRequest(url: addURL(url, with: name))) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemotePokemonDetailLoader.map(data: data, response: response))
            case .failure( _):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func addURL(_ url: URL, with name: String) -> URL {
        return url
          .appendingPathComponent("pokemon")
          .appendingPathComponent(name)
      }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let pokemonDetail = try PokemonDetailMapper.map(data, from: response)
            return .success(pokemonDetail)
        } catch {
            return .failure(error)
        }
    }
}

// MARK:- PokemonDetailLoader
extension MainQueueDispatchDecorator: PokemonDetailLoader where T == PokemonDetailLoader {
    public func load(name: String, completion: @escaping (PokemonDetailLoader.Result) -> Void) {
        decoratee.load(name: name) { [weak self] result in
            self?.dispatch{
                completion(result)
            }
        }
    }
}
