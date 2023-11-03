//
//  SceneDelegate.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import UIKit
import PokemonGameNetwork
import PokemonGamePokemonList
import PokemonGameMedia
import PokemonGamePokemonDetail

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let remoteURL = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151&offset=0")!
    let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private lazy var navController = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func makeAllPokemoViewController() -> AllPokemoViewController {
        let session = URLSession(configuration: .ephemeral)
        let remoteClient = URLSessionHTTPClient(session: session)
        let remoteLoader = RemotePokemonLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemotePokemonImageLoader(client: remoteClient)
        
        return AllPokemonUIComposer.compose(loader: remoteLoader, imageLoader: remoteImageLoader) { [weak self] name in
            guard let self else { return }
            let controller = self.makePokemoDetailViewController(name: name)
            self.navController.pushViewController(controller, animated: false)
        }
    }
    
    func makePokemoDetailViewController(name: String) -> PokemonDetailViewController {
        let session = URLSession(configuration: .ephemeral)
        let remoteClient = URLSessionHTTPClient(session: session)
        let remoteLoader = RemotePokemonDetailLoader(url: baseURL, client: remoteClient)
        let remoteImageLoader = RemotePokemonImageLoader(client: remoteClient)
        
        return PokemonDetailUIComposer.compose(loader: remoteLoader, pokemonName: name, imageLoader: remoteImageLoader)
    }
    
    func configureWindow() {
        navController.setViewControllers([makeAllPokemoViewController()], animated: false)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

