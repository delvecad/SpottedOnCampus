//
//  ChatViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/16/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class ChatViewController: JSQMessagesViewController {
    
    // Current user variables
    // This variable is given a value on segue from conversations
    // It also needs to be passed these variables from home and detail views
    let currentUser = API.User.CURRENT_USER?.uid
    var recieverID: String?
    var convoID: String?
    
    
    // References to the messages children in the database
    // Messages must be sent to both the sender's ref and the reciever's ref
    var CONVOS_REF_SELF = Database.database().reference().child("users").child((API.User.CURRENT_USER?.uid)!).child("convos")
    
    var MESSAGES_REF = Database.database().reference().child("messages")

    
    // Array of all of the messages in the thread
    var messages = [JSQMessage]()
    
    var avatarDict = [String: JSQMessagesAvatarImage]()
    
    


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.scrollToBottom(animated: false)

        print(currentUser!)
        print("RECIEVER: \(recieverID)")
        print("SenderID: \(self.senderId)")
        print("SenderName: \(self.senderDisplayName)")

        print("CONVOid:\(self.convoID!)")
        
        //set the title to the other user's username
//        API.User.observeUser(withId: recieverID!) { (user) in
//            self.navigationItem.title = user.username
//        }
        
        observeMessages()

    }
    
    
    func fetchCurrentUser() {
        API.User.observeCurrentUser { (user) in
            
            // Get the current user and set the currentUser variable to that user
            print("current user: \(self.currentUser!)")
            
//            // set the sender id to the current user id
//            self.senderId = "12345"
//            print("current user id: \(self.currentUser.id!)")
//            
//            self.senderDisplayName = "HEY YO"
//            print("current user: \(self.currentUser.username!)")
            
//            self.collectionView.reloadData()
        }
        
    }
    
    
    
    // UI FUNCTIONS
    
    // Performs an action when you press the send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // Test outputs
        print("Text message: \(text)")
        print("senderID: \(senderId)")
        print("displayName: \(senderDisplayName)")
        
        //create a new message node on the database with an auto unique ID
        let newMessage_Messages = MESSAGES_REF.child(convoID!).childByAutoId()
        let newMessage_Users_Self = CONVOS_REF_SELF.child(convoID!)
        let newMessage_Users_Recipient = Database.database().reference().child("users").child(self.recieverID!).child("convos").child(convoID!)
        
        
        // Set the data that is going to be placed at that location
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
        
        
        // Set that data in the two locations
        newMessage_Messages.setValue(messageData)
        newMessage_Users_Self.setValue(self.recieverID!)
        newMessage_Users_Recipient.setValue(API.User.CURRENT_USER?.uid)
        
        
        self.finishSendingMessage()
        
    }

    // Performs an action when the attach button is pressed
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        // FOR TESTING
        print("Accessory button pressed")
        
        // Present an image picker
        let imagePicker = UIImagePickerController()
        self.present(imagePicker, animated: true, completion: nil)
        
        // Set the image picker delegate so that it knows to act on its protocol
        imagePicker.delegate = self
        
    }
    
    
   
    
    // DATABASE FUNCTIONS
    
    func observeMessages() {
        MESSAGES_REF.child(self.convoID!).observe(.childAdded, with: { snapshot in
            // print(snapshot.value)
            if let dict = snapshot.value as? [String: AnyObject] {
                let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                self.observeUsers(senderId)
                switch mediaType {
                    
                case "TEXT":
                    
                    let text = dict["text"] as! String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                case "PHOTO":
                    
                    let photo = JSQPhotoMediaItem(image: nil)
                    let fileUrl = dict["fileUrl"] as! String
                    let downloader = SDWebImageDownloader.shared()
                    downloader.downloadImage(with: URL(string: fileUrl)!, options: [], progress: nil, completed: { (image, data, error, finished) in
                        DispatchQueue.main.async(execute: {
                            photo?.image = image
                            self.collectionView.reloadData()
                        })
                    })
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                    // Configures the photo bubble's appearance based on who sent it
                    if self.senderId == senderId {
                        photo?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        photo?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    
                default:
                    print("unknown data type")
                    
                }
                
                self.collectionView.reloadData()
                
            }
        })
    }
    
    
    
    func observeUsers(_ id: String)
    {
        Database.database().reference().child("users").child(id).observe(.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                let avatarUrl = dict["profileImageURL"] as! String
                
                self.setupAvatar(avatarUrl, messageId: id)
            }
        })
        
    }
    
    
    func setupAvatar(_ url: String, messageId: String)
    {
        if url != "" {
            let fileUrl = URL(string: url)
            let data = try? Data(contentsOf: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            self.avatarDict[messageId] = userImg
            self.collectionView.reloadData()
            
        } else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
            collectionView.reloadData()
        }
        
    }
    
    
    
    
    func sendMedia(_ picture: UIImage?) {
        
        // FOR TESTING
        print(picture)
        print(Storage.storage().reference())
        
        // Check it's not nil
        if let picture = picture {
            
            // Create the filepath where the image will be stored
            let filePath = "messages/\(API.User.CURRENT_USER?.uid)/\(Date.timeIntervalSinceReferenceDate)"
            
            // print the filepath FOR TESTING
            print(filePath)
            
            // Creates jpeg data
            let data = UIImageJPEGRepresentation(picture, 0.1)
            
            // create the metadata object where metadata will be stored
            let metadata = StorageMetadata()
            
            // Set the contentType metadata to 'image/jpg'
            metadata.contentType = "image/jpg"
            
            //upload the image with its metadata
            Storage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error)
                in
                
                // If there's an error, print out the error message
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                // set the fileUrl
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.MESSAGES_REF.child(self.convoID!).childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
                newMessage.setValue(messageData)
                
            }
            
        }
    }
    
    
    
    
    
    
    
    // COLLECTION VIEW SETUP
    
    
    //specifies number of cells to create
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // sets number of items in the collection to the number of messages in the array
        return messages.count
        
    }
    
    
    
    // Sets up the individual collection view cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Cet the cell to act as a JSQ cell
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        // Return that cell
        return cell
        
    }
    
    
    
    // Feed data to the correct collection view cell
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        // Feed the data in the array index corresponding to the index in the collection view
        return messages[indexPath.item]
        
    }
    
    
    
    // Configure UI to display messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        // Get the message from the messages array
        let message = messages[indexPath.item]
        
        // Provides tools for creating bubbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        // Configures the bubble based on whether it's incoming or outgoing
        if message.senderId == self.senderId {
            
            return bubbleFactory!.outgoingMessagesBubbleImage(with: .black)
        } else {
            
            return bubbleFactory!.incomingMessagesBubbleImage(with: .gray)
            
        }
        
    }
    
    
    
    // Configure avatar
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        
        return avatarDict[message.senderId]
    }
    
}







// IMAGE PICKER EXTENSION

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // FOR TESTING
        print("Did finish picking image")
        
        
        // Construct the message
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            sendMedia(picture)
        }
        
        // Dismiss the image picker
        self.dismiss(animated: true, completion: nil)
        
        // Reload the view to display new data
        collectionView.reloadData()
        
    }
}
