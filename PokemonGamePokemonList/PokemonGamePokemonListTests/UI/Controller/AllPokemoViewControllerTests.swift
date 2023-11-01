//
//  AllPokemoViewControllerTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 25/10/23.
//

import XCTest
import UIKit
import PokemonGamePokemonList
import PokemonGameMedia

final class AllPokemoViewControllerTests: XCTestCase {
    func test_loadAllPokemonActions_requestPokemonFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadPokemonCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadPokemonCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedPokemonReload()
        XCTAssertEqual(loader.loadPokemonCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedPokemonReload()
        XCTAssertEqual(loader.loadPokemonCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingPokemonIndicator_isVisibleWhileLoadingPokemon() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completePokemonLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedPokemonReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completePokemonLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadPokemonCompletion_rendersSuccessfullyLoadedPokemon() {
        let pokemon0 = makePokemon(name: "bulbasaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!)
        let pokemon1 = makePokemon(name: "ivysaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/2/")!)
        let pokemon2 = makePokemon(name: "venusaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/3/")!)
        let pokemon3 = makePokemon(name: "charmander", url: URL(string: "https://pokeapi.co/api/v2/pokemon/4/")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completePokemonLoading(with: [pokemon0], at: 0)
        assertThat(sut, isRendering: [pokemon0])

        sut.simulateUserInitiatedPokemonReload()
        loader.completePokemonLoading(with: [pokemon0, pokemon1, pokemon2, pokemon3], at: 1)
        assertThat(sut, isRendering: [pokemon0, pokemon1, pokemon2, pokemon3])
    }
    
    func test_loadPokemonCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let pokemon0 = makePokemon()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [pokemon0], at: 0)
        assertThat(sut, isRendering: [pokemon0])
        
        sut.simulateUserInitiatedPokemonReload()
        loader.completePokemonLoadingWithError(at: 1)
        assertThat(sut, isRendering: [pokemon0])
    }

    func test_pokemonView_loadsImageURLWhenVisible() {
        let pokemon0 = makePokemon(url: URL(string: "http://url-0.com")!)
        let pokemon1 = makePokemon(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [pokemon0, pokemon1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulatePokemonViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulatePokemonViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url, pokemon1.url], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_pokemonView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makePokemon(url: URL(string: "http://url-0.com")!)
        let image1 = makePokemon(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulatePokemonViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulatePokemonViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_pokemonViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [makePokemon(), makePokemon()])
        
        let view0 = sut.simulatePokemonViewVisible(at: 0)
        let view1 = sut.simulatePokemonViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_pokemonView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [makePokemon(), makePokemon()])
        
        let view0 = sut.simulatePokemonViewVisible(at: 0)
        let view1 = sut.simulatePokemonViewVisible(at: 1)
        XCTAssertNil(view0?.renderedImage, "Expected no image for first view while loading first image")
        XCTAssertNil(view1?.renderedImage, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertNotNil(view0?.renderedImage, "Expected image for first view once first image loading completes successfully")
        XCTAssertNil(view1?.renderedImage, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertNotNil(view0?.renderedImage, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertNotNil(view1?.renderedImage, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_pokemonViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [makePokemon(), makePokemon()])
        
        let view0 = sut.simulatePokemonViewVisible(at: 0)
        let view1 = sut.simulatePokemonViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_pokemonViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [makePokemon()])
        
        let view = sut.simulatePokemonViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_pokemonViewRetryAction_retriesImageLoad() {
        let pokemon0 = makePokemon(url: URL(string: "http://url-0.com")!)
        let pokemon1 = makePokemon(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [pokemon0, pokemon1])
        
        let view0 = sut.simulatePokemonViewVisible(at: 0)
        let view1 = sut.simulatePokemonViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url, pokemon1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url, pokemon1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url, pokemon1.url, pokemon0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url, pokemon1.url, pokemon0.url, pokemon1.url], "Expected fourth imageURL request after second view retry action")
    }

    func test_pokemonView_preloadsImageURLWhenNearVisible() {
        let pokemon0 = makePokemon(url: URL(string: "http://url-0.com")!)
        let pokemon1 = makePokemon(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [pokemon0, pokemon1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulatePokemonViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulatePokemonViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [pokemon0.url, pokemon1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_pokemonView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makePokemon(url: URL(string: "http://url-0.com")!)
        let image1 = makePokemon(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePokemonLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulatePokemonViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulatePokemonViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_loadCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "wait for background queue")
        DispatchQueue.global().async {
            loader.completePokemonLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: AllPokemoViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = AllPokemonUIComposer.compose(loader: loader, imageLoader: loader)
        trackForMemoryLeak(loader, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: AllPokemoViewController, isRendering pokemons: [Pokemon], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedPokemonViews() == pokemons.count else {
            return XCTFail("Expected \(pokemons.count) images, got \(sut.numberOfRenderedPokemonViews()) instead.", file: file, line: line)
        }
        
        pokemons.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: AllPokemoViewController, hasViewConfiguredFor pokemon: Pokemon, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.pokemonView(at: index)
        
        guard let cell = view as? PokemonCell else {
            return XCTFail("Expected \(PokemonCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.nameText, pokemon.name, "Expected description text to be \(pokemon.name) for image view at index (\(index)", file: file, line: line)
    }
    
    private func makePokemon(name: String = "any name", url: URL = URL(string: "http://any-url.com")!) -> Pokemon {
        return Pokemon(name: name, url: url)
    }

    class LoaderSpy: PokemonLoader, ImageLoader {
        
        // MARK: - PokemonLoader

        private var pokemonRequests = [(PokemonLoader.Result) -> Void]()
        
        var loadPokemonCallCount: Int {
            return pokemonRequests.count
        }
        
        func load(completion: @escaping (PokemonLoader.Result) -> Void) {
            pokemonRequests.append(completion)
        }
        
        func completePokemonLoading(with pokemons: [Pokemon] = [], at index: Int = 0) {
            pokemonRequests[index](.success(pokemons))
        }
        
        func completePokemonLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            pokemonRequests[index](.failure(error))
        }
        
        // MARK: - ImageDataLoader

        private struct TaskSpy: ImageLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }

        private var imageRequests = [(url: URL, completion: (ImageLoader.Result) -> Void)]()

        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }

        private(set) var cancelledImageURLs = [URL]()

        func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }

}

private extension AllPokemoViewController {
    func simulateUserInitiatedPokemonReload() {
        collectionView.refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulatePokemonViewVisible(at index: Int) -> PokemonCell? {
        return pokemonView(at: index) as? PokemonCell
    }
    
    func simulatePokemonViewNotVisible(at row: Int) {
        let view = simulatePokemonViewVisible(at: row)!
        
        let delegate = collectionView.delegate
        let index = IndexPath(row: row, section: pokemonsSection)
        delegate?.collectionView?(collectionView, didEndDisplaying: view, forItemAt: index)
    }
    
    func simulatePokemonViewNearVisible(at row: Int) {
        let ds = collectionView.prefetchDataSource
        let index = IndexPath(row: row, section: pokemonsSection)
        ds?.collectionView(collectionView, prefetchItemsAt: [index])
    }
    
    func simulatePokemonViewNotNearVisible(at row: Int) {
        simulatePokemonViewNearVisible(at: row)
        
        let ds = collectionView.prefetchDataSource
        let index = IndexPath(row: row, section: pokemonsSection)
        ds?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [index])
    }

    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedPokemonViews() -> Int {
        return collectionView.numberOfItems(inSection: pokemonsSection)
    }
    
    func pokemonView(at row: Int) -> UICollectionViewCell? {
        let ds = collectionView.dataSource
        let index = IndexPath(row: row, section: pokemonsSection)
        return ds?.collectionView(collectionView, cellForItemAt: index)
    }

    private var pokemonsSection: Int {
        return 0
    }
}

private extension PokemonCell {
    func simulateRetryAction() {
        pokemonImageRetryButton.simulateTap()
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return pokemonImageContainer.isShimmering
    }

    var isShowingRetryAction: Bool {
        return !pokemonImageRetryButton.isHidden
    }

    var nameText: String? {
        return nameLabel.text
    }
    
    var renderedImage: Data? {
        return pokemonImageView.image?.pngData()
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
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

