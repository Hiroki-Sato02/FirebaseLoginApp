//
//  UIColor-Extension.swift
//  FIrebaseLoginApp
//
//  Created by 佐藤大樹 on 2022/03/29.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
