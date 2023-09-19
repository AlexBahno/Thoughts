//
//  PostPreviewTableViewCell.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 15.09.2023.
//

import UIKit

class PostPreviewTableViewCellViewModel {
    let title: String
    let imageUrl: URL?
    var imageData: Data?
    let date: String
    let emailsOwner: String
    
    init(title: String, imageUrl: URL?, date: String, email: String) {
        self.title = title
        self.imageUrl = imageUrl
        self.date = date
        self.emailsOwner = email
    }
}

class PostPreviewTableViewCell: UITableViewCell {

    static let identifier = "PostPreviewTableViewCell"
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(activityIndicator)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(postTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        postTitleLabel.frame = CGRect(x: separatorInset.left, y: 5, width: contentView.width, height: 50)
//        postImageView.frame = CGRect(
//            x: separatorInset.left,
//            y: postTitleLabel.bottom + 5,
//            width: contentView.width - separatorInset.left * 2,
//            height: contentView.width - separatorInset.left * 2
//        )
        postImageView.frame = CGRect(
            x: separatorInset.left,
            y: 5,
            width: contentView.height - 10,
            height: contentView.height - 10
        )
        activityIndicator.frame = CGRect(
            x: separatorInset.left,
            y: 5,
            width: postImageView.width,
            height: postImageView.height
        )
        postTitleLabel.frame = CGRect(
            x: postImageView.right + 15,
            y: 5,
            width: contentView.width - 5 - separatorInset.left - postImageView.width,
            height: contentView.height - 10
        )
        dateLabel.frame = CGRect(
            x: postTitleLabel.right - 130,
            y: contentView.height - 20,
            width: contentView.width / 2,
            height: 20
        )
        ownerLabel.frame = CGRect(
            x: postTitleLabel.left,
            y: contentView.top,
            width: contentView.width / 2,
            height: 20
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postTitleLabel.text = nil
        postImageView.image = nil
        dateLabel.text = nil
        ownerLabel.text = nil
    }
    
    func configure(with viewModel: PostPreviewTableViewCellViewModel) {
        activityIndicator.startAnimating()
        postTitleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
        ownerLabel.text = viewModel.emailsOwner
        
        if let data = viewModel.imageData {
            postImageView.image = UIImage(data: data)
        }
        else if let url = viewModel.imageUrl {
            // Fetch Image & cache it
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else {
                    return
                }
                
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.postImageView.image = UIImage(data: data)
                    self?.activityIndicator.stopAnimating()
                }
            }
            task.resume()
        }
    }
}
