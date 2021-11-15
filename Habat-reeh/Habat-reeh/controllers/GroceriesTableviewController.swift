//
//  SignInViewController.swift
//  Habat-reeh
//
//  Created by Hamad Wasmi on 05/04/1443 AH.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import SwiftUI
class GroceriesTableviewController: UIViewController {
    
    //outlets
    
    @IBOutlet weak var OnlineButton: UIBarButtonItem!
    @IBOutlet weak var onlineBlinker: UIImageView!
    @IBOutlet weak var itemsTable: UITableView!
    
    //variables
    var itemS = [[String:Any]]()
    var item: [String] = []
    var OnlineEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        onOnline()
        updateStatus()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getallItems()
        DispatchQueue.main.async {
            self.itemsTable.reloadData()
        }
    }
    
    //MARK: FUNCTIONS: CRUD
    //1. function: add items to table and db
    func addItems(){
        guard let email = Auth.auth().currentUser?.email else{return}
        
        OnlineEmail = DBmanager.safeEmail(email)
        //guard let id = Auth.auth().currentUser?.uid else{return}
        let userId = UUID().uuidString
        let alert=UIAlertController(title: "Add new", message: "add item to grocery list", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let txtfield = alert.textFields![0]
        
        let saveNew = UIAlertAction(title: "Save", style: .default){_ in
            //self.item.append(txtfield.text ?? "")
            self.itemS.append(["items":txtfield.text as Any, "email":self.OnlineEmail])
            let grocery = Glist(item: txtfield.text!, emailAddress: self.OnlineEmail, quantity: 0)
            DBmanager.shared.insertItem(with: grocery, id: userId, completion: { success in
                if success{
                    print("user \(String(describing: userId)) inserted in database successfully")
                }else{
                    print("error, user \(String(describing: userId)) not inserted in database ")
                }
            })
            self.itemsTable.reloadData()
        }
        
        let cancelAdd = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveNew)
        alert.addAction(cancelAdd)
        self.present(alert, animated: true, completion: nil)
    }
    
    //2. function: read/get items to table and db
    func getallItems(){
        DBmanager.shared.database.child("Grocery_list").observeSingleEvent(of: .value, with: {
            snapsot in
            guard let values = snapsot.value as? [String:Any] else{
                print("error getting data")
                return
            }
            //print("va: \(values)")
            for val in values{
                
                guard let dbitems = ((val.value as AnyObject)["Item"]) as? String  else{return}
                guard let dbemails = ((val.value as AnyObject)["email"]) as? String else{return}
                let dbelement = ["items": dbitems,
                                 "email": dbemails,
                                 "keyID": val.key]
                self.item.append(val.key)
                self.itemS.append(dbelement)
                
                self.itemsTable.reloadData()
            }
        })
    }
    
    
    //MARK: buttons IBActions
    @IBAction func LogOutUser(_ sender: UIBarButtonItem) {
        guard let userid = Auth.auth().currentUser?.uid else{return}
        do{
            try
            Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
            
            DBmanager.shared.database.child("Is_Online").child(userid).setValue([nil])
            // .child(["ID":userid]).setValue(nil)
            print("sign out")
        }catch{
            print("error logging out\(error)")
        }
    }
    
    @IBAction func AddToList(_ sender: UIBarButtonItem) {
        addItems()
    }
    
    //MARK: additional functions
    func onOnline(){
        guard let user = Auth.auth().currentUser else{return}
        let userRef = DBmanager.onlineRef.child(user.uid)
        userRef.setValue(user.email)
        userRef.onDisconnectRemoveValue()
    }
    
    func updateStatus(){
        DBmanager.onlineRef.observe(.value, with: { snapshot in
            if snapshot.exists(){
                self.OnlineButton?.title = snapshot.childrenCount.description
                self.onlineBlinker.tintColor = UIColor.orange
            }else{
                self.OnlineButton.title = "0"
                self.onlineBlinker.tintColor = UIColor.gray
                
            }
        })
    }
    func popInfo(_ message: String) {
        let alert = UIAlertController(title: "online now", message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}


//MARK: TableView content/interactions
extension GroceriesTableviewController: UITableViewDelegate, UITableViewDataSource{
    //1.number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemS.count
    }
    //2.reusable cell: label content ,detail label content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //        cell.textLabel?.text = item[indexPath.row]
        
        cell.textLabel?.text = itemS[indexPath.row]["items"] as? String
        cell.detailTextLabel?.text = itemS[indexPath.row]["email"] as? String
        return cell
    }
    //3.delete item:cell swipe **  3. function: update/edit items to table and db
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let userID = self.itemS[indexPath.row]["keyID"] as? String else{return}
        
        if editingStyle == .delete {
            DBmanager.shared.database.child("Grocery_list").child(userID).setValue(nil)
            itemS.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            self.itemsTable.reloadData()
        }
    }
    
    //4.edit/update item: tap cell ** 4. function: delete items to table and db
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let email = Auth.auth().currentUser?.email else{return}//i want to add who edited it
        guard let userID = self.itemS[indexPath.row]["keyID"] as? String else{return}
        
        let alert=UIAlertController(title: "Add new", message: "edit item in grocery list", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let txtfield = alert.textFields![0]
        txtfield.text = self.itemS[indexPath.row]["items"] as? String
        
        let saveNew = UIAlertAction(title: "Save", style: .default){_ in
            
            self.itemS[indexPath.row]["items"] = txtfield.text!
            self.itemS[indexPath.row]["email"] = "edited by: " + email
            self.itemsTable.reloadData()
            
            let grocery = Glist(item: txtfield.text!, emailAddress: email, quantity: 1)
            DBmanager.shared.insertItem(with: grocery, id: userID, completion: { success in
                if success{
                    print("user \(String(describing: userID)) updated in database successfully")
                }else{
                    print("error, user \(String(describing: userID)) not updated in database ")
                }
            })
        }
        
        let cancelAdd = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveNew)
        alert.addAction(cancelAdd)
        self.present(alert, animated: true, completion: nil)
    }
}
