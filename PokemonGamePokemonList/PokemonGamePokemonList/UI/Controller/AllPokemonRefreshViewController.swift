//
//  AllPokemonRefreshViewController.swift
//  PokemonGamePokemonList
//
//  Created by Galih Samudra on 26/10/23.
//

import UIKit

public final class AllPokemonRefreshViewController: NSObject {
    private let pokemonLoader: PokemonLoader?
    var onRefresh: (([Pokemon]) -> Void)?
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    init(pokemonLoader: PokemonLoader? = nil) {
        self.pokemonLoader = pokemonLoader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        pokemonLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        })
    }
    
}
