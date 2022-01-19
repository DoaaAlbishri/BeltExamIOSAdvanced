//
//  GroceryViewController.swift
//  Grocery List App
//
//  Created by Doaa Albishri on 12/01/2022.
//

import UIKit
import FirebaseAuth
import Firebase

class GroceryViewController: UIViewController {
    //grocery list
    var groceryList = [[String:String]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        // fetch data from DB
        fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check if login in or not
        validateAuth()
    }
    
    // validate firebase authentication
    func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // present login view controller
            let vc = storyboard?.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
            
        }
    }
    // reference the database
    private let database = Database.database().reference()
    // handeler to detect change in real time
    private var yourHandler: DatabaseHandle?
    
    // get grocery items from DB
    func fetch(){
        let allItems = self.database.child("grocery-items")
        allItems.keepSynced(true)
        yourHandler =  allItems.observe(.value, with: { snapshot in
            var arr = [[String:String]]()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let itemDict = snap.value as! [String: Any]
                let name = itemDict["name"] as! String
                let addedByUser = itemDict["addedByUser"] as! String
                arr.append(itemDict as! [String:String])
                print(name,addedByUser)
            }
            self.groceryList = arr
            print(self.groceryList.count)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        if let handler = yourHandler {
            database.removeObserver(withHandle: handler)
        }
    }
    
    // add new item to grocery list
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        //show add alert
        let addAlert = UIAlertController(title: "Add item ", message: "Add the item to list to buy it", preferredStyle: .alert)
        
        addAlert.addTextField(configurationHandler: nil)
        let item =  addAlert.textFields![0]
        item.placeholder = "Enter item"
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default)
        {
            _ in
            let itemObj = GrocertItem(name: item.text! , addedByUser: UserDefaults.standard.value(forKey: "email") as! String)
            //insert new item to DB
            DatabaseManger.shared.insertItem(with: itemObj,completion: {_ in
            })
        }
        present(addAlert, animated: true, completion: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addAlert.addAction(saveAction)
        addAlert.addAction(cancelAction)
    }
    
}

extension GroceryViewController : UITableViewDataSource , UITableViewDelegate {
    // number of row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryList.count
    }
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath)
        cell.textLabel?.text = groceryList[indexPath.row]["name"]
        cell.detailTextLabel?.text = groceryList[indexPath.row]["addedByUser"]
        return cell
    }
    // delete item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //remove from DB
        let item = groceryList[indexPath.row]["name"]
        let safeItem = DatabaseManger.safeItem(item: item!)
        DatabaseManger.shared.removeItem(child: safeItem)
    }
    //update item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show edit alert
        let editAlert = UIAlertController(title: "Edit item ", message: "Edit item as you want ", preferredStyle: .alert)
        // name of old item
        let oldItem = self.groceryList[indexPath.row]["name"]
        editAlert.addTextField { (textField) -> Void in
            textField.text = oldItem
        }
        let item =  editAlert.textFields![0]
        
        let saveAction = UIAlertAction(title: "Edit", style: .default)
        {
            _ in
            // new name and email of user
            let safeOldItem = DatabaseManger.safeItem(item: oldItem!)
            let newItem = item.text!
            let email = UserDefaults.standard.value(forKey: "email") as! String
            //update item in DB
            DatabaseManger.shared.updateItem(oldChild: safeOldItem, newChild: newItem , email: email)
        }
        
        present(editAlert, animated: true, completion: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        editAlert.addAction(saveAction)
        editAlert.addAction(cancelAction)
        
        
    }
}

