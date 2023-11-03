//
//  AllPokemoViewController.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation
import UIKit

final public class AllPokemoViewController: UICollectionViewController {
    private var refreshController: AllPokemonRefreshViewController?
    var cellModel = [AllPokemonCellController]()  {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public convenience init(refreshController: AllPokemonRefreshViewController) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.collectionViewLayout = createLayout()
        collectionView.refreshControl = refreshController?.view
        collectionView.prefetchDataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: "PokemonCell")
        refreshController?.refresh()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width/4),
                                 height: (UIScreen.main.bounds.size.width/2))
        return layout
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> AllPokemonCellController {
        return cellModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }}
    
extension AllPokemoViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
}

extension AllPokemoViewController {
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).selectCell()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModel.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellController(forRowAt: indexPath).view(collectionView, at: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
}
