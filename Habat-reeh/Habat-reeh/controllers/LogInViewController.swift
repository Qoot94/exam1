//
//  LogInViewController.swift
//  Habat-reeh
//


import UIKit
import FirebaseAuth
import simd
//import simd

class LogInViewController: UIViewController {
    
    @IBOutlet weak var groceryImgView: UIView!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        groceryImgView.layer.cornerRadius=90
        
    }
    
    //MARK: FUNCTIONS
    //1.function: Logging in user with firebase
    func logInUser(){
        Auth.auth().signIn(withEmail: emailTxtField.text!, password:passwordTxtField.text!, completion: {
            authResult, error in
            //let userEmail = self.emailTxtField.text!
            
            guard let result = authResult , error == nil else{
                //pop error
                self.popAlert("sorry, \(String(describing: error?.localizedDescription ?? ""))")
                
                print("error logging in due to: \(String(describing: error))")
                return
            }
            //case: log in succeed
            let user = result.user
            let id = user.uid
            
            //user is online
            
            print("logged in user: \(user)")
            
            DBmanager.shared.userIsOnline(with: id, completion: { error in
                guard error  == false else {
                    print("failed to write to database")
                    return
                }
                print("user \(id) is online")
            })
            
            //allow access: go to main home screen
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "groceryVC") as! GroceriesTableviewController
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            
        })
    }
    
    //2.function: sign up/create User with firebase
    func creatUser(){
        DBmanager.shared.userExists(with: emailTxtField.text!, completion: {
            exist in
            //if user does exist
            if exist{
                self.popAlert("user already exists, try logging in instead")
            }//if user does not exist: creat one
            else if !exist{
                //if text field is empty: alert
                Auth.auth().createUser(withEmail: self.emailTxtField.text! , password: self.passwordTxtField.text!,completion:{
                    authresult, error in
                    guard let result = authresult, error == nil else {
                        self.popAlert("\(error?.localizedDescription ?? " " )")
                        print("Error creating user\(self.emailTxtField.text!) ,error:\(String(describing: error?.localizedDescription))")
                        return
                    }
                    //saftely send email characters to db
                    let user = result.user
                    print("created user: \(user), with \(self.emailTxtField.text!)")
                    self.popAlert("created user successfully, you can log in now")
                })
                
            }
        })
        
    }
    
    //3. function: showing error alert to user
    func popAlert(_ message: String) {
        let alert = UIAlertController(title: "warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    //MARK: buttons IBActions
    @IBAction func signUpUser(_ sender: UIButton) {
        creatUser()
        
    }
    @IBAction func logInUser(_ sender: UIButton) {
        logInUser()
    }
    
    
    
}

