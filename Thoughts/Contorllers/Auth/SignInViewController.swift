//
//  SignInViewController.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import UIKit

class SignInViewController: UIViewController {

    
    //MARK: Header View
    private let headerView = SigninHeaderView()
    
    //MARK: Email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.placeholder = "Email Address"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    //MARK: Password field
    private let passField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    //MARK: Sign in button
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //MARK: Create acc
    private let createAccButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign In"
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passField)
        view.addSubview(signInButton)
        view.addSubview(createAccButton)
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccButton.addTarget(self, action: #selector(didTapCreateAcc), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/5)
        
        emailField.frame = CGRect(x: 20, y: headerView.bottom, width: view.width-40, height: 50)
        passField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 50)
        signInButton.frame = CGRect(x: 20, y: passField.bottom+10, width: view.width-40, height: 50)
        createAccButton.frame = CGRect(x: 20, y: signInButton.bottom+40, width: view.width-40, height: 50)
    }
    
    //MARK: Signing in acc
    @objc func didTapSignIn() {
        guard let email = emailField.text, !email.isEmpty,
              let pass = passField.text, !pass.isEmpty else {
            return
        }
        
        AuthManager.shared.signIn(email: email, password: pass) { [weak self] result in
            if result {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(email, forKey: "email")
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            } else {
                print("Failed to sign in")
            }
        }
    }
    
    @objc func didTapCreateAcc() {
        let vc = SignUpViewController()
        vc.title = "Create Account"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
