//
//  ViewController.swift
//  CombineJustPublisher
//
//  Created by Sergei on 04.11.2023.
//

import Combine
import UIKit

struct User: Codable {
    let name: String
}

class ViewController: UIViewController {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    var observer: AnyCancellable?
    private var users: [User] = []
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(UITableViewCell.self,
                      forCellReuseIdentifier: "cell")
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        observer = fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.users = users
                self?.tableView.reloadData()
            })
    }

    
    func fetchUsers() -> AnyPublisher<[User], Never> {
        guard let url else {
            return Just([]).eraseToAnyPublisher()
        }
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [User].self, decoder: JSONDecoder())
            .catch { _ in
                Just([])
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
//        cell.action.sink { string in
//            print(string)
//        }
//        .store(in: &observers)
        
        return cell
    }
    
    
}
