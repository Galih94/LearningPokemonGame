//
//  PokemonCell.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import UIKit

public final class PokemonCell: UICollectionViewCell {
    public let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let pokemonImageContainer = UIView()
    public let pokemonImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private(set) public lazy var pokemonImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: ( () -> Void )?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        nameLabel.frame = CGRect(x: 5,
                                 y: contentView.frame.size.height - 50,
                                 width: contentView.frame.size.width-10,
                                 height: 50)

        pokemonImageContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.frame.size.width,
            height: contentView.frame.size.height - 50)
        pokemonImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: pokemonImageContainer.frame.size.width,
            height: pokemonImageContainer.frame.size.height)
        pokemonImageRetryButton.frame = CGRect(
            x: 0,
            y: 0,
            width: pokemonImageContainer.frame.size.width,
            height: pokemonImageContainer.frame.size.height)
        
    }
    
    public override func prepareForReuse() {
        pokemonImageView.image = nil
        nameLabel.text = nil
    }
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    func configureUI() {
        contentView.addSubview(pokemonImageContainer)
        contentView.addSubview(nameLabel)
        pokemonImageContainer.addSubview(pokemonImageView)
        pokemonImageContainer.addSubview(pokemonImageRetryButton)
        contentView.clipsToBounds = true
    }
}
