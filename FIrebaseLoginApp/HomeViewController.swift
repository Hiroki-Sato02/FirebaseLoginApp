//
//  HomeViewController.swift
//  FIrebaseLoginApp
//
//  Created by 佐藤大樹 on 2022/04/06.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    var user: User? {
        didSet {
            print("user?.name", user?.name)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func tappedLogoutButton(_ sender: Any) {
        handleLogout()
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch (let err) {
            print("ログアウトに失敗しました。\(err)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        if let user = user {
            nameLabel.text = user.name + "さんようこそ"
            emailLabel.text = user.email
            let dateString = dateFormatterForCreatedAt(date: user.createdAt.dateValue())
            dateLabel.text = "作成日： " + dateString
        }
        
    }
    
    private func dateFormatterForCreatedAt(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
