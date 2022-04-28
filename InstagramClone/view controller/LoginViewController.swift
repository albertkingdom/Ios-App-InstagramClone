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
    var validationService: ValidationService!
    var handle: AuthStateDidChangeListenerHandle?
    var signInMode: Bool = true {
        didSet {
            if signInMode {
                signUpButton.isHidden = true
                passwordInputFirst.placeholder = "Password at least 6 characters."
                passwordInputSecond.isHidden = true
                signInButton.isHidden = false
                switchModeButton.setTitle("註冊帳號", for: .normal)
            }
            if !signInMode {
                signUpButton.isHidden = false
                passwordInputFirst.placeholder = "Input Password."
                passwordInputSecond.isHidden = false
                signInButton.isHidden = true
                switchModeButton.setTitle("使用已有帳號進行登入", for: .normal)
              
            }
        }
    }
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInputFirst: UITextField!
    @IBOutlet weak var passwordInputSecond: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    @IBOutlet weak var separatorLine: UIView!
    @IBAction func pressButtonSignIn(_ sender: Any) {
        login()
    }
    @IBAction func pressButtonSignUp(_ sender: Any) {
        signUp()
    }
    @IBAction func pressSwitchModeButton() {
        signInMode = !signInMode
    }
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LoginViewController viewDidLoad")
        validationService = ValidationService()
        self.hideKeyboardWhenTappedAround()
        passwordInputFirst.textContentType = .password
        passwordInputSecond.textContentType = .password
        
        self.passwordInputFirst.setupRightButton(imageName: "eye")
        self.passwordInputSecond.setupRightButton(imageName: "eye")
        self.setupFBLoginButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        signInMode = true
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user, let email = user.email {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                
                let photoURL = user.photoURL
                
                print("user \(email)")
                
                self.performSegue(withIdentifier: "toTabBar", sender: nil)
            }
        }
    }
    func login() {
        guard let email = emailInput.text, let password = passwordInputFirst.text else {
            return
        }
       
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                 
            if error == nil {
                print("login success \(authResult)")
                
                self?.performSegue(withIdentifier: "toTabBar", sender: nil)
            } else {
                let alert = CustomAlertController.presentAlertStyle(title: "登入錯誤", message: error?.localizedDescription ?? "")
                self?.present(alert, animated: true)
               
            }
        }
    }
    func signUp() {
        guard let passwordFirst = passwordInputFirst.text, let passwordSecond = passwordInputSecond.text else { return }
        let validationPasswordResult = validationService.isSignUpPasswordValid(password1: passwordFirst, password2: passwordSecond)
        
        switch validationPasswordResult {
        case SignUpPasswordValidationResult.PasswordNotMatch:
            let alert = CustomAlertController.presentAlertStyle(title: "錯誤", message: "檢查密碼是否相同")
            self.present(alert, animated: true)
            return
        case SignUpPasswordValidationResult.PasswordLengthNotEnough:
            let alert = CustomAlertController.presentAlertStyle(title: "錯誤", message: "密碼長度不足")
            self.present(alert, animated: true)
            return
        default:
            guard let email = emailInput.text else { return }
            Auth.auth().createUser(withEmail: email, password: passwordFirst) { authResult, error in
                guard let error = error else {
                    
                    print("successful sign up")
                    
                    return
                }
                
                let alert = CustomAlertController.presentAlertStyle(title: "註冊結果", message: error.localizedDescription)
                self.present(alert, animated: true)
                
            }
            
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
        passwordInputFirst.text = nil
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
            print("fb email \(authResult?.user.email)")
            self.performSegue(withIdentifier: "toTabBar", sender: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("fb log out")
        
    }
    
   
}

