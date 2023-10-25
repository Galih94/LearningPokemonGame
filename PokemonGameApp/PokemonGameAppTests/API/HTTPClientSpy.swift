//
//  HTTPClientSpy.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 25/10/23.
//

import Foundation
import PokemonGameNetwork

final class HTTPClientSpy: HTTPClient {
    
    var cancelledURLs = [URL]()
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }
    
    var requestedURLs : [URL] {
        return messages.map { $0.url }
    }
    
    func request(from urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((urlRequest.url!, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(urlRequest.url!)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
