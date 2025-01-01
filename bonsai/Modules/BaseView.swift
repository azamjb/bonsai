//
//  BaseView.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import UIKit
class BaseView: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
    }
    
    func isAuthenticated() -> Bool {
        let bearer = UserDefaults.standard.string(forKey: LocalStorageKeys.bearer)
        let userId = UserDefaults.standard.string(forKey: LocalStorageKeys.userId)
        
        return bearer != nil && userId != nil
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if !isAuthenticated() {
            if viewController is SomeProtectedViewController {
                showLoginScreen()
                navigationController.popViewController(animated: true)
            }
        }
    }

    func showLoginScreen() {
        let loginVC = LoginView()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
