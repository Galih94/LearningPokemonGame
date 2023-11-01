//
//  MainQueueDispatchDecorator.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 25/10/23.
//

import Foundation
import PokemonGameMedia

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

// MARK:- PokemonLoader
extension MainQueueDispatchDecorator: PokemonLoader where T == PokemonLoader {
    public func load(completion: @escaping (PokemonLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

// MARK:- ImageLoader
extension MainQueueDispatchDecorator: ImageLoader where T == ImageLoader {
    public func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch{
                completion(result)
            }
        }
    }
}
