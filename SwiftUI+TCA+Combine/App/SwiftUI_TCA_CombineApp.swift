//
//  SwiftUI_TCA_CombineApp.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/19/25.
//

import SwiftUI
import ComposableArchitecture

class AppDelegate: NSObject, UIApplicationDelegate {
  static let shared: AppDelegate = {
    return UIApplication.shared.delegate as! AppDelegate
  }()
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    return true
  }
}

@main
struct SwiftUI_TCA_CombineApp: App {
  let persistenceController = PersistenceManager.shared
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      GitHubMainView(
        store: Store(
          initialState: GitHubMainFeature.State(),
          reducer: { GitHubMainFeature() }
        )
      )
//      .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
