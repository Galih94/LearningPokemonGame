//
//  RemotePokemonImageLoaderTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 25/10/23.
//

import XCTest
import PokemonGameMedia

final class RemotePokemonImageLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error: RemotePokemonImageLoader.Error = .connectivity
        
        expect(sut: sut, toCompeteWith: .failure(error)) {
            client.complete(with: error)
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let error = failure(.invalidData)
        let data = anyData()
        let codes = [199, 201, 300, 400, 500]
        
        codes.enumerated().forEach { index, code in
            expect(sut: sut, toCompeteWith: error) {
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let error = failure(.invalidData)
        let emptyData = Data()
        let code = 200
        
        expect(sut: sut, toCompeteWith: error) {
            client.complete(withStatusCode: code, data: emptyData, at: 0)
        }
    }
    
    func test_loadImageData_deliversDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let data = anyData()
        let code = 200
        
        expect(sut: sut, toCompeteWith: .success(data)) {
            client.complete(withStatusCode: code, data: data)
        }
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageData_doesNotDeloverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        var receivedResult = [ImageLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            receivedResult.append(result)
        }
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageData_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemotePokemonImageLoader? = RemotePokemonImageLoader(client: client)
        let data = anyData()
        let code = 200
        let url = anyURL()
        
        var capturedResults = [ImageLoader.Result]()
        _ = sut?.loadImageData(from: url, completion: { result in
            capturedResults.append(result)
        })
        
        sut = nil
        client.complete(withStatusCode: code, data: data)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemotePokemonImageLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePokemonImageLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemotePokemonImageLoader.Error) -> ImageLoader.Result {
        return .failure(error)
    }
    
    private func expect(sut: RemotePokemonImageLoader, toCompeteWith expectedResult: ImageLoader.Result, action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load image")
        _ = sut.loadImageData(from: url) { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let ( .success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as RemotePokemonImageLoader.Error), .failure(expectedError as RemotePokemonImageLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default: XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
}
