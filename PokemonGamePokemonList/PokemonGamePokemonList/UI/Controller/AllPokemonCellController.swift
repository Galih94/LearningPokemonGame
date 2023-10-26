//
//  AllPokemonCellController.swift
//  PokemonGamePokemonList
//
//  Created by Galih Samudra on 26/10/23.
//

import UIKit

final class AllPokemonCellController {
    private var task: ImageLoaderTask?
    private let model: Pokemon
    private let imageLoader: ImageLoader
    
    init(model: Pokemon, imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func preload() {
        task = self.imageLoader.loadImageData(from: self.model.url, completion: { _ in })
    }
    
    func view(_ collectionView: UICollectionView, at indexPath: IndexPath) -> PokemonCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
        cell.nameLabel.text = model.name
        cell.pokemonImageView.image = nil
        cell.pokemonImageRetryButton.isHidden = true
        cell.pokemonImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.pokemonImageView.image = image
                cell?.pokemonImageRetryButton.isHidden = (image != nil)
                cell?.pokemonImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}

