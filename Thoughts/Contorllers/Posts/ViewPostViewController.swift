//
//  ViewPostViewController.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import UIKit

class ViewPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let post: BlogPost
    
    init(post: BlogPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        // title, header, body
        // Poster
        let table = UITableView()
        table.separatorStyle = .none
        table.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        table.register(
            PostHeaderTableViewCell.self,
            forCellReuseIdentifier: PostHeaderTableViewCell.identifier
        )
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // title, image, text
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch index {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            
            // Configure content.
            content.text = post.title
            content.secondaryText = post.date
            content.textProperties.numberOfLines = 0
            content.textProperties.font = .systemFont(ofSize: 24, weight: .bold)

            cell.contentConfiguration = content
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PostHeaderTableViewCell.identifier,
                for: indexPath
            ) as? PostHeaderTableViewCell else {
                fatalError()
            }
            cell.selectionStyle = .none
            cell.configure(with: .init(imageUrl: post.headerImageUrl))
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            
            // Configure content.
            content.text = post.text
            content.textProperties.numberOfLines = 0
            content.textProperties.font = .systemFont(ofSize: 20)
            
            content.secondaryText = post.emailOfOwner
            content.secondaryTextProperties.font = .systemFont(ofSize: 13)
            
            cell.contentConfiguration = content
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        switch index {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 300
        case 2:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
}
