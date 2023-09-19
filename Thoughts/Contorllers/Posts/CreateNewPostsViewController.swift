//
//  CreateNewPostsViewController.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import UIKit

class CreateNewPostsViewController: UIViewController {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    var fetchPosts: ( () -> () )?
    
    // Title field
    private let titleField: UITextField = {
        let field = UITextField()
        field.keyboardType = .twitter
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .yes
        field.placeholder = "Title..."
        field.backgroundColor = .secondarySystemBackground
        field.layer.masksToBounds = true
        return field
    }()
    
    // Image Header
    private let headerImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "photo")
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    
    // TextView for post
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 28)
        textView.backgroundColor = .secondarySystemBackground
        textView.keyboardType = .twitter
        textView.autocorrectionType = .yes
        textView.autocapitalizationType = .sentences
        return textView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var selectedHeaderImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(headerImageView)
        view.addSubview(titleField)
        view.addSubview(textView)
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapHeader)
        )
        headerImageView.addGestureRecognizer(tap)
        configureButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleField.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width - 20, height: 50)
        headerImageView.frame = CGRect(x: 0, y: titleField.bottom + 5, width: view.width, height: 160)
        textView.frame = CGRect(x: 10, y: headerImageView.bottom + 10,
                                width: view.width - 20,
                                height: view.height - 210 - view.safeAreaInsets.top
        )
    }
    
    private func configureButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(didTapCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost)
        )
    }
    
    @objc private func didTapHeader() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPost() {
        // Check data and create post
        guard let title = titleField.text,
              let body = textView.text,
              let headerImage = selectedHeaderImage,
              let email = UserDefaults.standard.string(forKey: "email"),
              !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !body.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            let alert = UIAlertController(
                title: "Enter Post Details",
                message: "Please, enter a title, body and select a image to continue",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        //activityIndicator.startAnimating()
        showActivityIndicatory(uiView: view)
        
        let postId = UUID().uuidString
        // Upload Header Image
        StorageManager.shared.uploadBlogHeaderImage(
            email: email,
            image: headerImage,
            postId: postId) { result in
                guard result else {
                    return
                }
                StorageManager.shared.downloadUrlForPostHeader(email: email, postId: postId) { result in
                    switch result {
                    case .success(let url):
                        //Insert of post into DB
                        let post = BlogPost(
                            identifier: postId,
                            title: title,
                            timestamp: Date().timeIntervalSince1970,
                            headerImageUrl: url,
                            text: body,
                            emailOfOwner: UserDefaults.standard.string(forKey: "email") ?? ""
                        )
                        
                        DatabaseManager.shared.insert(blogPost: post, email: email) { [weak self] posted in
                            guard posted else {
                                print("Failed to upload post")
                                return
                            }
                            //self?.activityIndicator.stopAnimating()
                            self?.hideActivityIndicator(uiView: (self?.view)!)
                            DispatchQueue.main.async {
                                self?.fetchPosts!()
                                self?.didTapCancel()
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
    }
}

extension CreateNewPostsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        selectedHeaderImage = image
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.headerImageView.image = image
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)

        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.5)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(uiView: UIView) {
            activityIndicator.stopAnimating()
            container.removeFromSuperview()
        }
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
            let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
            let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
            let blue = CGFloat(rgbValue & 0xFF)/256.0
            return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
        }
}
