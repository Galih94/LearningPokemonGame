//
//  HTTPClient.swift
//  PokemonGameNetwork
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func request(from urlRequest: URLRequest, completion: @escaping (Result) -> Void)
}

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func request(from urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: urlRequest) { data, response, error in
            completion(Result{
                if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else if let error = error {
                    throw error
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
