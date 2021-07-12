//
//  LoginViewController.swift
//  Messenger
//
//  Created by TomaszGolkowski on 01/07/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let FBloginButton: FBLoginButton = {
        let button  = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    private let googleLogInButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        GIDSignIn.sharedInstance().presentingViewController = self
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        FBloginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(FBloginButton)
        scrollView.addSubview(googleLogInButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width/3
        imageView.frame = CGRect(x: (view.width-size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom+10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+20, width: scrollView.width-60, height: 52)
        FBloginButton.frame = CGRect(x: 30, y: loginButton.bottom+10, width: scrollView.width-60, height: 52)
        googleLogInButton.frame = CGRect(x: 30, y: FBloginButton.bottom+10, width: scrollView.width-60, height: 52)

    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginErrror()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in with email: \(email)")
                return
            }
            let user = result.user
            print("Succesfully log in: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginErrror() {
        let alert = UIAlertController(title: "Something went wrong!", message: "Enter email and password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: - Delegate email and password
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

// MARK: - Delegate facebook button
extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Failed to log in via facebook.")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("failed to make faceboook graph request")
                return
            }
            //print(result)
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let pictureURL = data["url"] as? String else {
                print("Failed to get name and email")
                return
            }

            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            
                            guard let url = URL(string: pictureURL) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url,completionHandler: { data, _, error in
                                guard let data = data else {
                                    return
                                }
                                let filename = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    }
                }
            })
            
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            guard authResult != nil, error == nil else {
                if let error = error {
                    print("Facebook credential login, MFA may be needed - \(error)")
                }
                return
            }
            print("Successfully login by facebook")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
}
