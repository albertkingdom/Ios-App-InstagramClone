//
//  LoginViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/9/21.
//

import UIKit
import FirebaseAuth
import FacebookLogin

class LoginViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
 
    @IBOutlet weak var separatorLine: UIView!
    @IBAction func pressButtonSignIn(_ sender: Any) {
        login()
    }
    @IBAction func pressButtonSignUp(_ sender: Any) {
        signUp()
    }
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LoginViewController viewDidLoad")
        passwordInput.textContentType = .password
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
              // The user's ID, unique to the Firebase project.
              // Do NOT use this value to authenticate with your backend server,
              // if you have one. Use getTokenWithCompletion:completion: instead.
                
                let email = user.email
                let photoURL = user.photoURL
                
                print("user \(email)")
                
                
                
                //self.present(controller, animated: true, completion: nil)
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
        
        self.passwordInput.setupRightButton(imageName: "eye")
        self.setupFBLoginButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func login() {
        guard let email = emailInput.text, let password = passwordInput.text else {
            return
        }
       
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                 
            if error == nil {
                print("login success \(authResult)")
                
                self?.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
    }
    func signUp() {
        guard let email = emailInput.text, let password = passwordInput.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          print("successful sign up")
        }
    }
    func setupFBLoginButton() {
        let loginButton = FBLoginButton() // facebook sdk built-in button view
        let subView = UIView()
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        // 能夠取用的user資料權限，預設只有"public_profile"
        loginButton.permissions = ["public_profile", "email"]
        

        
        view.addSubview(loginButton)
        
        // autolayout
        NSLayoutConstraint.activate([
           
            loginButton.centerXAnchor.constraint(equalTo: separatorLine.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalTo: separatorLine.widthAnchor, multiplier: 0.5),
           
            
        ])
        
        loginButton.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        emailInput.text = nil
        passwordInput.text = nil
    }
    


}
extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let token = AccessToken.current else {
            return
        }
        
        
        let credential = FacebookAuthProvider
            .credential(withAccessToken: token.tokenString)
        
        
        Auth.auth().signIn(with: credential) { authResult, error in
            
            if let error = error {
                print("fb auth error..\(error)")
            }
            print("fb auth result...\(authResult)")
            self.performSegue(withIdentifier: "toTabBar", sender: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("fb log out")
        
    }
    
   
}

