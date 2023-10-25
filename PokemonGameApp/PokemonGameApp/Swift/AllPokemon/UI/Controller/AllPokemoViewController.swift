//
//  AllPokemoViewController.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation
import UIKit

final public class AllPokemoViewController: UICollectionViewController {
    private var pokemonLoader: PokemonLoader?
    private var imageLoader: ImageLoader?
    private var cellModel = [Pokemon]()
    private var tasks = [IndexPath: ImageLoaderTask]()
    
    public convenience init(pokemonLoader: PokemonLoader, imageLoader: ImageLoader) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.pokemonLoader = pokemonLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        collectionView.prefetchDataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: "PokemonCell")
        load()
    }
    
    @objc private func load() {
        collectionView.refreshControl?.beginRefreshing()
        pokemonLoader?.load { [weak self] result in
            if let pokemons = try? result.get() {
                self?.cellModel = pokemons
                self?.collectionView.reloadData()
            }
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
}
    
extension AllPokemoViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = cellModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}

extension AllPokemoViewController {
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
        let cellModel = cellModel[indexPath.row]
        cell.nameLabel.text = cellModel.name
        cell.pokemonImageView.image = nil
        cell.pokemonImageRetryButton.isHidden = true
        cell.pokemonImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
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
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
}

extension AllPokemoViewController {
    private var numberOfCellInARow: CGFloat {
        return 2
    }
    
    private var margin: CGFloat {
        return 16
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((UIScreen.main.bounds.size.width) / numberOfCellInARow) - margin
        
        return CGSize(width: width, height: width)
    }
}
