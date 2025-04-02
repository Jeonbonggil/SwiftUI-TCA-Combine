//
//  CommonFunc.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/3/24.
//

import UIKit
import CoreData

struct Application {
  static var keyWindow: UIWindow {
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    let window = windowScene?.windows.first ?? UIWindow()
    return window
  }
}

struct Screen {
  static var width: CGFloat {
    return UIScreen.main.bounds.width
  }
  static var height: CGFloat {
    return UIScreen.main.bounds.height
  }
  static var statusBarHeight: CGFloat {
    return Application.keyWindow.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
  }
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate
