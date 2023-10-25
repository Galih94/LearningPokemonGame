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

// MARK:- MainQueueDispatchDecorator
public final class MainQueueDispatchDecorator<T> {
    
    private(set) public var decoratee: T
    
    public init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    public func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}



extension MainQueueDispatchDecorator: PokemonLoader where T == PokemonLoader {
    public func load(completion: @escaping (PokemonLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: ImageLoader where T == ImageLoader {
    public func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch{
                completion(result)
            }
        }
    }
}
