//
//  AllPokemonUIComposer.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 25/10/23.
//

import Foundation

public enum AllPokemonUIComposer {
    public static func compose(loader: PokemonLoader, imageLoader: ImageLoader) -> AllPokemoViewController {
        
        let viewController = AllPokemoViewController(pokemonLoader: MainQueueDispatchDecorator(decoratee: loader), imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        
        return viewController
    }
}
