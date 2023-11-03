//
//  RemotePokemonImageLoader.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 25/10/23.
//

import PokemonGameNetwork
import Foundation
import PokemonGameCommon

public final class RemotePokemonImageLoader: ImageLoader {
    private final class HTTPClientTaskWrappper: ImageLoaderTask {
        var wrapped: HTTPClientTask?
        private var completion: ((ImageLoader.Result) -> Void)?
        
        init(_ completion: (@escaping (ImageLoader.Result) -> Void) ) {
            self.completion = completion
        }
        
        func complete(with result: ImageLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        let task = HTTPClientTaskWrappper(completion)
        task.wrapped = client.request(from: URLRequest(url: url)) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError{ _ in Error.connectivity}
                .flatMap { (data, response) in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
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
