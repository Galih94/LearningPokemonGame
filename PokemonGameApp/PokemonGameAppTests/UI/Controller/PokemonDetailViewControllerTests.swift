//
//  PokemonDetailViewControllerTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 27/10/23.
//

import XCTest
import PokemonGameApp

final class PokemonDetailViewControllerTests: XCTestCase {
    
    func test_pokemonDetailView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Pokemon Detail")
    }
    
    func test_loadPokemonDetail_requestPokemonDetailsFromLoader() {
        let (sut, loader) = makeSUT(pokemonName: "weedle")
        XCTAssertEqual(loader.loadPokemonCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadPokemonCallCount, 1, "Expected a loading request once view is loaded")
    }
    
    func test_loadingPokemonDetailIndicator_isVisibleWhileLoading() {
        let name = "weedle"
        let (sut, loader) = makeSUT(pokemonName: name)
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isLoading, "Expected loading indicator once view is loaded")
        XCTAssertTrue(sut.vStack.isHidden, "Expected vStack hidden once view is loaded")
        XCTAssertTrue(sut.pokemonImageView.isHidden, "Expected pokemonImageView hidden once view is loaded")
        
        loader.completePokemonDetailLoading(with: makePokemonDetail(), at: name)
        XCTAssertFalse(sut.isLoading, "Expected no loading indicator once loading completes successfully")
        XCTAssertFalse(sut.vStack.isHidden, "Expected vStack show once loading completes successfully")
        XCTAssertFalse(sut.pokemonImageView.isHidden, "Expected pokemonImageView show once loading completes successfully")
    }
    
    func test_loadingPokemonDetail_pokemonDetailShown() {
        let name = "weedle"
        let pokemonDetail = makePokemonDetail()
        let (sut, loader) = makeSUT(pokemonName: name)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.nameLabel.text, nil, "Expected empty name label once view is loaded")
        XCTAssertEqual(sut.typeLabel.text, nil, "Expected empty type label once view is loaded")
        XCTAssertEqual(sut.moveLabel.text, nil, "Expected empty move label once view is loaded")
        
        loader.completePokemonDetailLoading(with: pokemonDetail, at: name)
        XCTAssertEqual(sut.nameLabel.text, pokemonDetail.name, "Expected empty name label once view is loaded")
        XCTAssertEqual(sut.typeLabel.text, pokemonDetail.types.joined(separator: ","), "Expected empty type label once view is loaded")
        XCTAssertEqual(sut.moveLabel.text, pokemonDetail.moves.joined(separator: ","), "Expected empty move label once view is loaded")
    }
    
    //MARK: Helpers
    private func makeSUT(pokemonName: String = "", file: StaticString = #filePath, line: UInt = #line) -> (sut: PokemonDetailViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PokemonDetailViewController(pokemonDetailLoader: loader, pokemonName: pokemonName)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: PokemonDetailLoader {
        // MARK: - PokemonLoader

        private var pokemonDetailRequests = [String: (PokemonDetailLoader.Result) -> Void]()
        
        var loadPokemonCallCount: Int {
            return pokemonDetailRequests.count
        }
        
        
        func load(name: String, completion: @escaping (PokemonDetailLoader.Result) -> Void) {
            pokemonDetailRequests[name] = completion
        }
        
        func completePokemonDetailLoading(with pokemon: PokemonDetail, at name: String) {
            let completion = pokemonDetailRequests[name]
            completion?(.success(pokemon))
        }
        
        func completePokemonDetailLoadingWithError(at name: String) {
            let error = NSError(domain: "an error", code: 0)
            let completion = pokemonDetailRequests[name]
            completion?(.failure(error))
        }
    }
}

private extension PokemonDetailViewController {
//    var isShowingLoadingIndicator: Bool {
//        return
//    }
}
