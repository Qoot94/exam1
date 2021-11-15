//
//  DBmanager.swift
//  Habat-reeh
//


import Foundation
import FirebaseAuth
import FirebaseDatabase


struct Glist{
    let item: String
    let emailAddress: String
    let quantity: Int
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


class DBmanager{
    
    static let shared=DBmanager()
    let database = Database.database().reference()
    static let onlineRef = Database.database().reference(withPath: "Is_Online")
 
    
    static func safeEmail(_ emailAddress: String)-> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    //MARK: Database-related Functions
    //1.check if user exists
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
    //2.Insert new user to database
    public func insertItem(with user: Glist, id: String ,completion: @escaping (Bool) -> Void){
        
        database.child("Grocery_list").child(id).setValue(["email":user.safeEmail,"Item":user.item, "quantity": user.quantity]) { error, _ in
            guard error  == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
    //4.check users who are online
    public func userIsOnline(with id: String ,completion: @escaping (Bool) -> Void){
        
        database.child("Is_Online").child(id).setValue("on") { error, _ in
            guard error  == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
  
}
