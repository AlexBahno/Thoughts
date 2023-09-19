//
//  ViewController.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let composeButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(
            UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
            ),
            for: .normal)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(PostPreviewTableViewCell.self, forCellReuseIdentifier: PostPreviewTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(composeButton)
        composeButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        fetchAllPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeButton.frame = CGRect(
            x: view.frame.width - 80 - 8,
            y: view.frame.height - 80 - 8 - view.safeAreaInsets.bottom,
            width: 60, height: 60
        )
        tableView.frame = view.bounds
    }

    @objc private func didTapCreate() {
        let vc = CreateNewPostsViewController()
        vc.title = "Create Post"
        vc.fetchPosts = { [weak self] in
            self?.fetchAllPosts()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private var posts: [BlogPost] = []
    
    private func fetchAllPosts() {
        print("Fetching Home Feed...")
        
        DatabaseManager.shared.getAllPosts { [weak self] result in
            switch result {
            case .success(let posts):
                self?.posts = posts
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewTableViewCell.identifier, for: indexPath) as? PostPreviewTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(title: post.title, imageUrl: post.headerImageUrl, date: post.date, email: post.emailOfOwner))
//        var content = cell.defaultContentConfiguration()
//
//        // Configure content.
//        content.text = post.title
//        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ViewPostViewController(post: posts[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
}

