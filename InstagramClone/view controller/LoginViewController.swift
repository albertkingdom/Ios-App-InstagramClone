//
//  LoginViewController.swift
//  InstagramClone
//
//  Created by 林煜凱 on 12/9/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBAction func pressButtonSignIn(_ sender: Any) {
        login()
    }
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
    func login() {
        guard let email = emailInput.text, let password = passwordInput.text else {
            return
        }
       
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
         
          
            if error == nil {
                print(authResult)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        emailInput.text = nil
        passwordInput.text = nil
    }
    


}
