 //
//  MessagesViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//
//
//  This VC will be the list of all open chats, and it will lead to the chat vc, which is a single thread

import UIKit
import FirebaseDatabase

class MessagesViewController: UIViewController {

    // Current user variables
    var currentUser: User!
    var postID: String!
    var conversations = [Conversation]()
    var conversationIDs = [String]()
    var users = [User]()
    var userConvos = [Dictionary<String, Any>]()
    
    var selectedRecipientID: String?
    var selectedConvoID: String?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Handles tableView specifications
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension

        fetchCurrentUser()
        
        loadConversations()
    }
    
    
    
    func loadConversations() {
        
        print()
        print("Reached loadConversations")
        
        print(conversations.count)
        
        API.User.REF_USERS.child((API.User.CURRENT_USER?.uid)!).child("convos").observe(.childAdded, with: {
            snapshot in
            
            print("Snapshot of load")
            print(snapshot.key)
            self.conversationIDs.insert(snapshot.key, at: 0)
            
            
            API.Conversation.observeConvos(withId: snapshot.key, completion: { (convo) in
                print()
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print("Conversation Snapshot: \(convo)")
                
                // Fetch the user
                self.fetchUser(uid: snapshot.value as! String, completed: {
                    
                    // append to the conversations array
                    self.conversations.insert(convo, at: 0)
                    print("Conversations array count: \(self.conversations.count)")
                    print("Users array count: \(self.users.count)")
                    
                    // reload the table view to display data
                    self.tableView.reloadData()
                })
            })
        })
    }
    
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid, completion: { user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // For chat segue, after selecting a conversation
        if segue.identifier == "chatSegue" {
            
            
            
            
            
            let chatVC = segue.destination as! ChatViewController
//            let convoID = sender as! String
            chatVC.convoID = selectedConvoID
            chatVC.recieverID = selectedRecipientID
            chatVC.senderId = API.User.CURRENT_USER!.uid
            chatVC.senderDisplayName = currentUser.username
//            chatVC.recieverID = self.specifiedPost?.uid!
            
            
        }
    }
    
    func fetchCurrentUser() {
        API.User.observeCurrentUser { (user) in
            
            // Get the current user and set the currentUser variable to that user
            self.currentUser = user
            
        }
    }
    
    
    
    
 }
    
    
    
    
    
 extension MessagesViewController: UITableViewDataSource, UITableViewDelegate {
    // determines how many cells we want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count

    }
    
    //deternmines how each cell looks
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ConversationTableViewCell
        
        let convo = conversations[indexPath.row]

        let user = users[indexPath.row]

        
        cell.conversation = convo
        cell.user = user
//        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        let currentUserID = API.User.CURRENT_USER?.uid
        self.selectedConvoID = self.conversationIDs[indexPath.row]
        
        
        print(indexPath.row)
        if(currentUserID == self.conversations[indexPath.row].recipientID){
            print(API.User.observeUser(withId: self.conversations[indexPath.row].solicitorID!, completion: { (user) in
                print(user.username!)
                self.selectedRecipientID = user.username!
            }))
        }
        else {
            print(API.User.observeUser(withId: self.conversations[indexPath.row].recipientID!, completion: { (user) in
                print(user.username!)
                self.selectedRecipientID = user.username!
            }))
        }
        
        
        
        performSegue(withIdentifier: "chatSegue", sender: nil)
        
    }
    
 }

