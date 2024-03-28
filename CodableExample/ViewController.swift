//
//  ViewController.swift
//  CodableExample
//
//  Created by Alessandro Fiss Garcez on 22/02/24.
//

import UIKit

var counter = 0

struct ResponseData: Decodable {
    var posts: [Post]
}

final class ViewController: UIViewController {
    
    private var state: ViewState = .loading

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        registerCells()
        loadData()
    }
    
    private func loadData() {
        state = .loading
        tableView.reloadData()
        requestData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let posts):
                let states = self.makeCellState(posts: posts)
                self.state = .success(posts: states)
            case .failure(let _):
                self.state = .failure(state: .init(text: "An error has occured"))
            }
            self.tableView.reloadData()
            
        }
    }
    
    private func makeCellState(posts: [Post]) -> [DefaultTableViewCell.State] {
        posts.map {
            switch $0.content {
            case .image: return .init(text: "Image")
            case .text: return .init(text: "Text")
            case .embedded: return .init(text: "Post")
            }
        }
    }
    
    private func registerCells() {
        tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.identifier)
    }
    
    
    @IBAction private func didTapButton(_ sender: UIButton) {
        loadData()
    }
}

extension ViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.posts.isEmpty ? 1 : state.posts.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = DefaultTableViewCell.identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                       for: indexPath) as? DefaultTableViewCell else {
            fatalError()
        }
        
        switch state {
        case .success(let postStates): cell.set(state: postStates[indexPath.row])
        case .loading: cell.set(state: .init(text: "Loading..."))
        case .failure(let errorStates): cell.set(state: errorStates)
        }
        return cell
    }
}

enum ServerError: Error {
    case parsingError
    case undefined
}

//Server
extension ViewController {
    
    private func requestData(handler: @escaping (Result<[Post], Error>) -> Void) {
        
        let file = counter%2 == 0 ? "example" : "example2"
        let data = loadJson(filename: file)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            if counter%3 == 0 {
                handler(.failure(ServerError.parsingError))
                return
            }
            if let posts = data?.posts {
                handler(.success(posts))
            } else {
                handler(.failure(ServerError.parsingError))
            }
        }
        counter+=1
    }
    
    func loadJson(filename fileName: String) -> ResponseData? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Foundation.Data(contentsOf: url)
                let jsonData = try decoder.decode(ResponseData.self, from: data)
                return jsonData
            } catch {
                return nil
            }
        }
        return nil
    }
}

enum ViewState {
    case loading
    case success(posts: [DefaultTableViewCell.State])
    case failure(state: DefaultTableViewCell.State)
    
    var posts: [DefaultTableViewCell.State] {
        switch self {
        case .success(let posts): return posts
        default: return []
        }
    }
}
