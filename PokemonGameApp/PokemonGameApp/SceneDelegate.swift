//
//  SceneDelegate.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 24/10/23.
//

import UIKit
import PokemonGameNetwork

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let remoteURL = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151&offset=0")!
    private lazy var navController = UINavigationController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
//        let session = URLSession(configuration: .ephemeral)
//        let remoteClient = URLSessionHTTPClient(session: session)
//        let remoteLoader = RemotePokemonLoader(url: remoteURL, client: remoteClient)
//        let remoteImageLoader = RemotePokemonImageLoader(client: remoteClient)
//        
//        let controller = AllPokemonUIComposer.compose(loader: remoteLoader, imageLoader: remoteImageLoader)
//
//        navController.setViewControllers([controller], animated: false)
//        window?.rootViewController = navController
//        window?.makeKeyAndVisible()
    }
}

