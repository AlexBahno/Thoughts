//
//  SigninHeaderView.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 03.09.2023.
//

import UIKit

class SigninHeaderView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logoclipped"))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()

    private let label: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Explore millions of Thoughts!"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(label)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = width/4
        imageView.frame = CGRect(x: (width-size)/2, y: 10, width: size, height: size)
        label.frame = CGRect(x: 20, y: imageView.bottom+10, width: width-40, height: height-size-30)
    }
}
