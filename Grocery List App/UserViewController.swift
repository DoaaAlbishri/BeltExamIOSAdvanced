//
//  UserViewController.swift
//  Grocery List App
//
//  Created by Doaa Albishri on 12/01/2022.
//

import UIKit
import FirebaseAuth
import Firebase
class UserViewController: UIViewController {
    //users list
    var users = [[String:String]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        // logout the user
        // show alert
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            // action that is fired once selected
            
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let email = DatabaseManger.safeEmail(emailAddress: UserDefaults.standard.value(forKey: "email") as! String)
                DatabaseManger.shared.remove(child: email)
                // present login view controller
                let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("failed to logout")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        //get users from BD
        fetch()
        //tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //get users from BD
        //        fetch()
        //        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        //get users from BD
        //        fetch()
        //        tableView.reloadData()
    }
    // reference the database
    private let database = Database.database().reference()
    // handeler to detect change in real time
    private var yourHandler: DatabaseHandle?
    // get online users from DB
    public func fetch(){
        let allOnlineUsers = self.database.child("online")
        allOnlineUsers.keepSynced(true)
        yourHandler =  allOnlineUsers.observe(.value, with: { snapshot in
            var arr = [[String:String]]()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let userDict = snap.value as! [String: Any]
                let email = userDict["email"] as! String
                arr.append(userDict as! [String:String])
                print(email)
            }
            self.users = arr
            print(self.users.count)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        if let handler = yourHandler {
            database.removeObserver(withHandle: handler)
        }
    }
}
extension UserViewController : UITableViewDelegate , UITableViewDataSource{
    // number of row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]["email"]
        return cell
    }
}
