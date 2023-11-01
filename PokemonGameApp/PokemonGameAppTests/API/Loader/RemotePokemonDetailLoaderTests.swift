//
//  RemotePokemonDetailLoaderTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 27/10/23.
//

import XCTest
import PokemonGameNetwork
import PokemonGameApp

final class RemotePokemonDetailLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let (url, expectedURL, name) = makeURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load(name: name){ _ in }
        
        XCTAssertEqual(client.requestedURLs, [expectedURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (url, expectedURL, name) = makeURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load(name: name){ _ in }
        sut.load(name: name){ _ in }
        
        XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientsError = NSError(domain: "Test", code: 0)
            client.complete(with: clientsError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makePokemonDetailJSON()
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let pokemonDetail = makePokemonDetail()
        let pokemonDetailJSON = makePokemonDetailJSON()
        
        expect(sut, toCompleteWithResult: .success(pokemonDetail)) {
            client.complete(withStatusCode: 200, data: pokemonDetailJSON)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let (url, _, _) = makeURL()
        let client = HTTPClientSpy()
        var sut: RemotePokemonDetailLoader? = RemotePokemonDetailLoader(url: url, client: client)
        var capturedResults = [RemotePokemonDetailLoader.Result]()
        sut?.load(name: anyName()) {
            capturedResults.append($0)
        }
        sut = nil
        let json = makePokemonDetailJSON()
        client.complete(withStatusCode: 200, data: json)
        XCTAssertTrue(capturedResults.isEmpty)
    }

    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemotePokemonDetailLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePokemonDetailLoader(url: url , client: client)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemotePokemonDetailLoader.Error) -> RemotePokemonDetailLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemotePokemonDetailLoader, toCompleteWithResult expectedResult: RemotePokemonDetailLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load(name: anyName()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems.name, expectedItems.name, file: file, line: line)
                XCTAssertEqual(receivedItems.imageURL.absoluteString, expectedItems.imageURL.absoluteString, file: file, line: line)
                XCTAssertEqual(receivedItems.types, expectedItems.types, file: file, line: line)
                XCTAssertEqual(receivedItems.moves, expectedItems.moves, file: file, line: line)
            case let (.failure(receivedError as RemotePokemonDetailLoader.Error), .failure(expectedError as RemotePokemonDetailLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makePokemonDetailJSON() -> Data {
        let bundlePath = Bundle.main.path(forResource: "weedle", ofType: "json")!
        let data = try! String(contentsOfFile: bundlePath).data(using: .utf8)!
        return data
    }
    
    private func makeURL() -> (url: URL, expectedURL: URL, name: String) {
        let url = URL(string: "https://a-given-url.com")!
        let name = "weedle"
        let expectedURL = URL(string: "https://a-given-url.com/pokemon/weedle")!
        
        return (url: url, expectedURL: expectedURL, name: name)
    }
    
    private func anyName() -> String {
        return "any name"
    }
}

private class HTTPClientSpy: HTTPClient {
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private struct Task: HTTPClientTask {
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
