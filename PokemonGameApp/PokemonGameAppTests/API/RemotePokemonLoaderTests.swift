//
//  RemotePokemonLoaderTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 24/10/23.
//

import XCTest
import PokemonGameNetwork
import PokemonGameApp

final class RemotePokemonLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load{ _ in }
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientsError = NSError(domain: "Test", code: 0)
            client.complete(with: clientsError) // need this to trigger error from client
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: json, at: index) // need this to trigger error from client
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON) // need this to trigger error from client
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyListJSON) // need this to trigger error from client
        }
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(
            name: "bulbasaur",
            jsonURL: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!,
            url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/1.png")!)
    
        let item2 = makeItem(
            name: "charmander",
            jsonURL: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!,
            url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/4.png")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJSON(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json) // need this to trigger error from client
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemotePokemonLoader? = RemotePokemonLoader(url: url, client: client)
        var capturedResults = [RemotePokemonLoader.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        sut = nil
        let emptyListJSON = makeItemsJSON(items: [])
        client.complete(withStatusCode: 200, data: emptyListJSON) // need this to trigger error from client
        XCTAssertTrue(capturedResults.isEmpty)
    }

    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemotePokemonLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePokemonLoader(url: url , client: client)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemotePokemonLoader.Error) -> RemotePokemonLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemotePokemonLoader, toCompleteWithResult expectedResult: RemotePokemonLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemotePokemonLoader.Error), .failure(expectedError as RemotePokemonLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action() // need this to trigger error from client
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(name: String, jsonURL: URL, url: URL) -> (model: Pokemon, json: [String: Any]) {
        let item = Pokemon(name: name, url: url)
        let json: [String: Any] = [
            "name": name,
            "url": jsonURL.absoluteString
        ].compactMapValues{$0}
        return (item, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let itemsJSON = [
            "results": items
        ]
        
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        var requestedURLs : [URL] {
            return messages.map { $0.url }
        }
        
        func request(from urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((urlRequest.url!, completion))
            return Task()
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

}
