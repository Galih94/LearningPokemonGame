//
//  PokemonDetailViewController.swift
//  PokemonGameApp
//
//  Created by Galih Samudra on 27/10/23.
//

import UIKit
import PokemonGamePokemonList

final public class PokemonDetailViewController: UIViewController {
    
    private var pokemonDetailLoader: PokemonDetailLoader? = nil
    private var pokemonName: String = ""
    
    private var task: ImageLoaderTask? = nil
    private var imageLoader: ImageLoader? = nil
    
    public convenience init(pokemonDetailLoader: PokemonDetailLoader, pokemonName: String, imageLoader: ImageLoader) {
        self.init(nibName: nil, bundle: nil)
        self.pokemonDetailLoader = pokemonDetailLoader
        self.pokemonName = pokemonName
        self.imageLoader = imageLoader
    }
    
    public var isLoading: Bool = false {
        didSet {
            self.isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
            self.vStack.isHidden = self.isLoading
            self.pokemonImageView.isHidden = self.isLoading
        }
    }
    
    private(set) public lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private(set) public var vStack: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fill
        view.isHidden = true
        return view
    }()
    
    private(set) public var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .tertiarySystemBackground
        return view
    }()
    
    private(set) public var nameLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .preferredFont(forTextStyle: .title3)
        view.textColor = .label
        view.numberOfLines = 0
        return view
    }()
    
    private(set) public var typeLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .preferredFont(forTextStyle: .subheadline)
        view.textColor = .label
        view.numberOfLines = 0
        return view
    }()
    
    private(set) public var moveLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .label
        view.numberOfLines = 0
        return view
    }()
    
    override public func viewDidLoad() {
        title = "Pokemon Detail"
        configureUI()
        load()
    }
    
    private func load() {
        isLoading = true
        pokemonDetailLoader?.load(name: pokemonName, completion: { [weak self] result in
            self?.isLoading = false
            let pokemonDetail = try? result.get()
            self?.nameLabel.text = pokemonDetail?.name
            self?.typeLabel.text = pokemonDetail?.types.joined(separator: ",")
            self?.moveLabel.text = pokemonDetail?.moves.joined(separator: ",")
            self?.setUpImage(url: pokemonDetail?.imageURL)
        })
    }
    
    private func setUpImage(url: URL?) {
        guard let url else { return }
        task = imageLoader?.loadImageData(from: url) { [weak self] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            self?.pokemonImageView.image = image
        }
    }
    
    private func configureUI() {
        
        view.backgroundColor = .tertiarySystemBackground
        
        [nameLabel, typeLabel, moveLabel].forEach(vStack.addArrangedSubview)
        vStack.setCustomSpacing(10, after: nameLabel)
        
        [pokemonImageView, loadingIndicator, vStack].forEach(view.addSubview)
        NSLayoutConstraint.activate([
            pokemonImageView.topAnchor.constraint(equalTo: view.topAnchor),
            pokemonImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pokemonImageView.bottomAnchor.constraint(equalTo: vStack.topAnchor),
            pokemonImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pokemonImageView.heightAnchor.constraint(equalTo: view.widthAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            vStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    deinit {
        task?.cancel()
    }
}
