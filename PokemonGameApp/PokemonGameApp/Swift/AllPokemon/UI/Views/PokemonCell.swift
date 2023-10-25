//
//  PokemonCell.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import UIKit

public final class PokemonCell: UICollectionViewCell {
    public var nameLabel = UILabel()
    public var pokemonImageContainer = UIView()
    public var pokemonImageView = UIImageView()
    
    private(set) public lazy var pokemonImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: ( () -> Void )?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
