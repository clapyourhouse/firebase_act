//
//  ViewController.swift
//  firebase_crud_sample
//
//  Created by shogo.kitamura on 11/7/18.
//  Copyright © 2018 shogo.kitamura. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    enum textFieldKind:Int {
        case name = 1
        case message = 2
    }
    var defaultstore:Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate宣言し、入力時の処理をViewControllerClassへ委任する
        messageTextField.delegate = self
        nameTextField.delegate = self
        //firebaseへのコネクション開始
        defaultstore = Firestore.firestore()
        //addSnapshotListenerでかfirebaseを監視して実行
        defaultstore.collection("chat").addSnapshotListener { (snapShot, error) in
            //不正な値だったら処理を抜ける
            guard let value = snapShot else {
                print("snapShot is nil")
                return
            }
            value.documentChanges.forEach{diff in
                //更新内容が追加だった時
                if diff.type == .added {
                    //追加された値を変更に入れる
                    let chatDataOp = diff.document.data() as? Dictionary<String, String>
                    guard let chatData = chatDataOp else {
                        return
                    }
                    guard let message = chatData["message"] else {
                        return
                    }
                    guard let name = chatData["name"] else {
                        return
                    }
                    //textViewに新しいメッセージを追加
//                    self.textView.tex =  "\(self.textView.text!)\n\(name) : \(message)"

                }
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
}
extension ViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("returnが押されたよ")
        //キーボードを閉じる
        textField.resignFirstResponder()
        //nameTextFieldの場合は　returnを押してもFirestoreへ行く処理をしない
        if textField.tag == textFieldKind.name.rawValue {
            return true
        }
        //nameに入力されたテキストを変数に入れる。nilの場合はFirestoreへ行く処理をしない
        guard let name = nameTextField.text else {
            return true
        }
        
        //nameが空欄の場合はFirestoreへ行く処理をしない
        if nameTextField.text == "" {
            return true
        }
        
        //messageに入力されたテキストを変数に入れる。nilの場合はFirestoreへ行く処理をしない
        guard let message = messageTextField.text else {
            return true
        }
        
        //messageが空欄の場合はFirestoreへ行く処理をしない
        if messageTextField.text == "" {
            return true
        }
        
        //入力された値を配列に入れる
        let messageData: [String: String] = ["name":name, "message":message]
        
        //Firestoreに送信する
        defaultstore.collection("chat").addDocument(data: messageData)
        //メッセージの中身を空にする
        messageTextField.text = ""
        
        return true
    }
    
}

