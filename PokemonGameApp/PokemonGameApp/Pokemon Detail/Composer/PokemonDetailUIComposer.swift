//
//  PokemonDetailUIComposer.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 01/11/23.
//

import Foundation
import PokemonGameMedia
import PokemonGameCommon

public enum PokemonDetailUIComposer {
    public static func compose(loader: PokemonDetailLoader, pokemonName: String, imageLoader: ImageLoader) -> PokemonDetailViewController {
        let viewController = PokemonDetailViewController(pokemonDetailLoader: MainQueueDispatchDecorator(decoratee: loader), pokemonName: pokemonName, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader) )
        
        return viewController
    }
}
