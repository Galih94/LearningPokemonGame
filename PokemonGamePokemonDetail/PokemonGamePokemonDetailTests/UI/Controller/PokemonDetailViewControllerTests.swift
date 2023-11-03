//
//  PokemonDetailViewControllerTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 27/10/23.
//

import XCTest
import PokemonGamePokemonDetail
import PokemonGameMedia

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
        let (name, pokemonDetail) = makePokemonNameAndDetail()
        let (sut, loader) = makeSUT(pokemonName: name)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.nameLabel.text, nil, "Expected empty name label once view is loaded")
        XCTAssertEqual(sut.typeLabel.text, nil, "Expected empty type label once view is loaded")
        XCTAssertEqual(sut.moveTextView.text, "", "Expected empty move label once view is loaded")
        
        loader.completePokemonDetailLoading(with: pokemonDetail, at: name)
        XCTAssertEqual(sut.nameLabel.text, pokemonDetail.name, "Expected empty name label once load successfull")
        XCTAssertEqual(sut.typeLabel.text, pokemonDetail.types.joined(separator: ", "), "Expected empty type label once load successfull")
        XCTAssertEqual(sut.moveTextView.text, pokemonDetail.moves.joined(separator: ", "), "Expected empty move label once load successfull")
    }
    
    func test_loadingPokemonDetail_pokemonImageLoad() {
        let (name, pokemonDetail) = makePokemonNameAndDetail()
        let (sut, loader) = makeSUT(pokemonName: name)
        
        sut.loadViewIfNeeded()
        XCTAssertNil(sut.pokemonImageView.image, "Expected empty image once view is loaded")
        
        loader.completePokemonDetailLoading(with: pokemonDetail, at: name)
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0)
        XCTAssertNotNil(sut.pokemonImageView.image, "Expected not empty image once view is loaded")
    }
    
    func test_doesNotLoadImage_onInstanceDeallocated() {
        let (name, pokemonDetail) = makePokemonNameAndDetail()
        let loader = LoaderSpy()
        var sut: PokemonDetailViewController? = PokemonDetailViewController(pokemonDetailLoader: loader, pokemonName: name, imageLoader: loader)
        
        sut?.loadViewIfNeeded()
        loader.completePokemonDetailLoading(with: pokemonDetail, at: name)
        XCTAssertTrue(loader.cancelledImageURLs.isEmpty, "Expected empty cancelled url after load pokemon detail")
        
        sut = nil
        addTeardownBlock {
            XCTAssertEqual(loader.cancelledImageURLs, [pokemonDetail.imageURL], "Expected cancelled url when sut in deinitialized before load image is completed")
        }
    }
    
    func test_loadCompletion_dispatchesFromBackgroundToMainThread() {
        let (name, pokemonDetail) = makePokemonNameAndDetail()
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "wait for background queue")
        DispatchQueue.global().async {
            loader.completePokemonDetailLoading(with: pokemonDetail, at: name)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: Helpers
    private func makeSUT(pokemonName: String = "", file: StaticString = #filePath, line: UInt = #line) -> (sut: PokemonDetailViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PokemonDetailUIComposer.compose(loader: loader, pokemonName: pokemonName, imageLoader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makePokemonNameAndDetail() -> (String, PokemonDetail) {
        return ("weedle", makePokemonDetail())
    }
    
    class LoaderSpy: PokemonDetailLoader, ImageLoader {
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
        
        // MARK: - ImageLoader
        private var imageRequests = [(url: URL, completion: (ImageLoader.Result) -> Void)]()
        private(set) var cancelledImageURLs = [URL]()
        private struct TaskSpy: ImageLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
