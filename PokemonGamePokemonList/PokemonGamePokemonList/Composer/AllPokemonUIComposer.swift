//
//  AllPokemonUIComposer.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 25/10/23.
//

import Foundation

public enum AllPokemonUIComposer {
    public static func compose(loader: PokemonLoader, imageLoader: ImageLoader) -> AllPokemoViewController {
        let refreshController = AllPokemonRefreshViewController(pokemonLoader: MainQueueDispatchDecorator(decoratee: loader))
        let viewController = AllPokemoViewController(refreshController: refreshController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        refreshController.onRefresh = adaptPokemonToCellControllers(forwardingTo: viewController)
        
        return viewController
    }
    
    private static func adaptPokemonToCellControllers(forwardingTo controller: AllPokemoViewController) -> (([Pokemon]) -> Void) {
        return { [weak controller] pokemon in
            controller?.cellModel = pokemon
        }
    }
}
