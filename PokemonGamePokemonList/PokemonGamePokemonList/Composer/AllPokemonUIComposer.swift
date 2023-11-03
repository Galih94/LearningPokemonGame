//
//  AllPokemonUIComposer.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 25/10/23.
//

import Foundation
import PokemonGameMedia
import PokemonGameCommon

public enum AllPokemonUIComposer {
    public static func compose(loader: PokemonLoader, imageLoader: ImageLoader, onSelected: @escaping (String) -> Void) -> AllPokemoViewController {
        let refreshController = AllPokemonRefreshViewController(pokemonLoader: MainQueueDispatchDecorator(decoratee: loader))
        let viewController = AllPokemoViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptPokemonToCellControllers(forwardingTo: viewController, with: MainQueueDispatchDecorator(decoratee: imageLoader), onSelected: onSelected)
        
        return viewController
    }
    
    private static func adaptPokemonToCellControllers(forwardingTo controller: AllPokemoViewController, with imageLoader: ImageLoader, onSelected: @escaping (String) -> Void) -> (([Pokemon]) -> Void) {
        
        return { [weak controller] pokemon in
            controller?.cellModel = pokemon.map { model in
                AllPokemonCellController(model: model, imageLoader: imageLoader, onSelected: onSelected)
            }
        }
    }
}
