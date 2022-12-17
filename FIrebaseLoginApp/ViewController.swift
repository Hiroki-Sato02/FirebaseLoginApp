//
//  ViewController.swift
//  FIrebaseLoginApp
//
//  Created by 佐藤大樹 on 2022/03/29.
//

import UIKit
import Firebase
import PKHUD

struct User {
    
    let name: String
    let createdAt: Timestamp
    let email: String
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as! String
        self.createdAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var RegistarButton: UIButton!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PassWordTextField: UITextField!
    @IBOutlet weak var UserNameTextField: UITextField!
    
    @IBAction func tappedRegistarButton(_ sender: Any) {
            handleAuthToFirebase()
    }
    private func handleAuthToFirebase() {
        HUD.show(.progress, onView: view)
        guard let email = EmailTextField.text else { return }
        guard let password = PassWordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            self.addUserInfoToFirestore(email: email)
        }
    }
    
    
    private func addUserInfoToFirestore(email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let name = self.UserNameTextField.text else { return }
        
        let docData = ["email": email, "name": name, "createdAt": Timestamp()] as [String : Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData(docData) { (err) in
            if let err = err {
                print("Firestoreへの保存に失敗しました。\(err)")
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            print("Firestoreへの保存に成功しました。")
            
            userRef.getDocument { (snapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let user = User.init(dic: data)
                print("ユーザー情報の取得ができました。\(user.name)")
                HUD.hide { (_) in
                    //HUD.flash(.success, delay: 1)
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        self.presentToHomeViewController(user: user)
                    }
                }
            }
        }
    }
    
    private func presentToHomeViewController(user: User) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.user = user
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        RegistarButton.layer.cornerRadius = 10
        RegistarButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        
        EmailTextField.delegate = self
        PassWordTextField.delegate = self
        UserNameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification: Notification) {
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let registarbuttonMaxY = RegistarButton.frame.maxY
        let distance = registarbuttonMaxY - keyboardMinY + 20
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
    }
    
    @objc func hideKeyboard() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let EmailisEmpty = EmailTextField.text?.isEmpty ?? true
        let PasswordisEmpty = PassWordTextField.text?.isEmpty ?? true
        let Usernameisempty = UserNameTextField.text?.isEmpty ?? true
        
        if EmailisEmpty || PasswordisEmpty || Usernameisempty {
            RegistarButton.isEnabled = false
            RegistarButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            RegistarButton.isEnabled = true
            RegistarButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}

