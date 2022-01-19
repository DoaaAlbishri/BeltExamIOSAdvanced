//
//  DatabaseManger.swift
//  Grocery List App
//
//  Created by Doaa Albishri on 12/01/2022.
//

import Foundation
import FirebaseDatabase

final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    static func safeItem(item: String) -> String {
        var safeItem = item.replacingOccurrences(of: ".", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "@", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "#", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "$", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "[", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "]", with: "-")
        safeItem = safeItem.replacingOccurrences(of: ",", with: "-")
        safeItem = safeItem.replacingOccurrences(of: " ", with: "-")
        return safeItem
    }
}
// MARK: - account management
extension DatabaseManger {
    
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child("all-users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        }
    }
    
    /// Insert new user to database
    public func insertUser(with user: GroceryAppUser , completion: @escaping (Bool) -> Void ){
        database.child("online").child(user.safeEmail).setValue(["email":user.emailAddress], withCompletionBlock: { [weak self] error , _ in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else{
                print("Failed to write to database")
                completion(false)
                return
            }
            
            strongSelf.database.child("all-users").child(user.safeEmail).setValue(["email":user.emailAddress])
            
            completion(true)
        })
    }
    
    /// remove online user from database (sign out)
    public func remove(child: String) {
        let ref = self.database.child("online").child(child)
        ref.removeValue { error, _ in
            guard error == nil else{
                print(error!)
                return
            }
        }
        ref.keepSynced(true)
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
    // MARK: - grocery Item management
    /// Insert new item to database
    public func insertItem(with item: GrocertItem , completion: @escaping (Bool) -> Void ){
        database.child("grocery-items").child(item.safeItem).setValue(["name":item.name,"addedByUser":item.addedByUser], withCompletionBlock: { error , _ in
            
            guard error == nil else{
                print("Failed to write to database")
                completion(false)
                return
            }
            
        })
    }
    
    /// remove item from database
    public func removeItem(child: String) {
        
        let ref = self.database.child("grocery-items").child(child)
        
        ref.removeValue { error, _ in
            guard error == nil else{
                print(error!)
                return
            }
        }
        ref.keepSynced(true)
    }
    /// update/edit  item in database
    public func updateItem(oldChild:String ,newChild:String, email: String){
        //database.child("grocery").child(oldChild).updateChildValues(["name": newChild])
        removeItem(child: oldChild)
        insertItem(with: GrocertItem(name: newChild, addedByUser: email), completion: {_ in
        })
    }
    
}
// user struct
struct GroceryAppUser {
    let emailAddress: String
    // create a computed property safe email
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
// item struct
struct GrocertItem{
    var name: String
    let addedByUser: String
    var safeItem : String {
        var safeItem = name.replacingOccurrences(of: ".", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "@", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "#", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "$", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "[", with: "-")
        safeItem = safeItem.replacingOccurrences(of: "]", with: "-")
        safeItem = safeItem.replacingOccurrences(of: ",", with: "-")
        safeItem = safeItem.replacingOccurrences(of: " ", with: "-")
        return safeItem
    }
}
