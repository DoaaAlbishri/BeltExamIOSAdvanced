//
//  AccountViewController.swift
//  Grocery List App
//
//  Created by Doaa Albishri on 12/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class AccountViewController: UIViewController {
    //email and password text field outlet
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //spinner
    private let spinner = JGProgressHUD(style: .dark)
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    // sign up button pressed
    // insert new user to firebase
    @IBAction func signUPButton(_ sender: UIButton) {
        // check all text fields not empty
        guard let email = email.text,
              let password = password.text,
              !email.isEmpty,
              !password.isEmpty
        else{
            //toast
            // if the text filds is empty
            showToast(controller: self, message : "Fill all the filed please", seconds: 2.0)
            return
        }
        spinner.show(in: view)
        
        //check if the email is exisit or not
        DatabaseManger.shared.userExists(with: email, completion : {
            [weak self ] exists in
            
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                  strongSelf.spinner.dismiss()
            }
            guard  !exists  else {
                //user already exists
                strongSelf.showToast(controller: strongSelf, message : "user already exists", seconds: 2.0)
                return
            }
            
            // Firebase Login / check to see if email is taken
            // try to create an account
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult , error  in
                
                //part 5
                guard authResult != nil , error == nil else {
                    print("Error creating user")
                    strongSelf.showToast(controller: strongSelf, message : "The account has not been created", seconds: 2.0)
                    return
                }
                
                let ChatUser = GroceryAppUser(emailAddress: email)
                //insert user to firebase
                DatabaseManger.shared.insertUser(with: ChatUser, completion: {_ in
                    
                })
                UserDefaults.standard.set(email, forKey: "email")
                // if this succeeds, dismiss
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "GroceryViewController") as! GroceryViewController
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            })
        })
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        // check all text fields not empty
        guard let email = email.text,
              let password = password.text,
              !email.isEmpty,
              !password.isEmpty
        else{
            //toast
            // if the text filds is empty
            showToast(controller: self, message : "Fill all the filed please", seconds: 2.0)
            return
        }
        spinner.show(in: view)
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                   strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                strongSelf.showToast(controller: strongSelf, message : "The email or password is not correct", seconds: 2.0)
                return
            }
            let ChatUser = GroceryAppUser(emailAddress: email)
            DatabaseManger.shared.insertUser(with: ChatUser, completion: {_ in
                
            })
            UserDefaults.standard.set(email, forKey: "email")
            let user = result.user
            print("logged in user: \(user)")
            // if this succeeds, dismiss
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: "GroceryViewController") as! GroceryViewController
            strongSelf.navigationController?.pushViewController(vc, animated: true)
            
        })
    }
    //toast
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}
