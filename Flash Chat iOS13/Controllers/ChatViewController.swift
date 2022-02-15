//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
//    var message: [Message] = [Message(sender: "1@a.com", body: "Hello 2"), Message(sender: "2@a.com", body: "Hello 1"), Message(sender: "1@a.com", body: "What's going on! wlneflwd  wocwns cowncowcpewj cwej cijc wicuh wi")]
    var message: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier
        )
        loadMessages()
    }
    func loadMessages(){
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshot, err) in
            self.message = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("No of messages are: \(querySnapshot?.documents.count ?? 0)")
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    let mess = document.data()
                    if let sendr = mess[K.FStore.senderField] as? String, let bdy = mess[K.FStore.bodyField] as? String{
                        self.message.append(Message(sender: sendr, body: bdy))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
//                        print(self.message.count)
//                        print(sendr, bdy)
                    }
                    else{
                        print("Error retreiving data from Firestore")
                    }
                }
            }
        }
    }
    
    @IBAction func signOutClicked(_ sender: UIButton) {
            let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
      
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageSender = Auth.auth().currentUser?.email, let messageBody = messageTextfield.text{
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let e = error{
                    print("Error saving data to Firestore \(e)")
                }
                else{
                    print("Data saved successfully to Firestore!")
                }
            }
        }
//        loadMessages()
//        tableView.reloadData()
//        print(message)
        messageTextfield.text = ""
    }
    
//    func createCell(indexPath: ){
//        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
//        cell.label.text = message[indexPath.row].body
//    }
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message[indexPath.row].body
        return cell
    }
    
    
}
