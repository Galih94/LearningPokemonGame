//
//  Helpers.swift
//  PokemonGameNetworkTests
//
//  Created by Galih Samudra on 24/10/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any domain error", code: 0)
}

private func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func makeURLRequest() -> URLRequest {
    return URLRequest(url: anyURL())
}
