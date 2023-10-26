//
//  SceneDelegateTests.swift
//  PokemonGameAppTests
//
//  Created by Galih Samudra on 26/10/23.
//

import XCTest
import PokemonGamePokemonList
@testable import PokemonGameApp

final class SceneDelegateTests: XCTestCase {
    func test_sceneWillConnectToSession_configuresRootViewController() {
            let sut = SceneDelegate()
            sut.window = UIWindow()

            sut.configureWindow()

            let root = sut.window?.rootViewController
            let rootNavigation = root as? UINavigationController
            let topController = rootNavigation?.topViewController

            XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
            XCTAssertTrue(topController is AllPokemoViewController, "Expected a conversion view controller as top view controller, got \(String(describing: topController)) instead")
        }

}
