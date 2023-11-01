//
//  PokemonDetailUIComposer.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 01/11/23.
//

import Foundation
import PokemonGamePokemonList
import PokemonGameMedia

public enum PokemonDetailUIComposer {
    public static func compose(loader: PokemonDetailLoader, pokemonName: String, imageLoader: ImageLoader) -> PokemonDetailViewController {
        let viewController = PokemonDetailViewController(pokemonDetailLoader: MainQueueDispatchDecorator(decoratee: loader), pokemonName: pokemonName, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader) )
        
        return viewController
    }
}

// TODO: Need to separate MainQueueDispatchDecorator
// MARK:- ImageLoader
extension MainQueueDispatchDecorator: PokemonDetailLoader where T == PokemonDetailLoader {
    public func load(name: String, completion: @escaping (PokemonDetailLoader.Result) -> Void) {
        decoratee.load(name: name) { [weak self] result in
            self?.dispatch{
                completion(result)
            }
        }
    }
}
