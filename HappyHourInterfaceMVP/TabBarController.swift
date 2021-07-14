//
//  TabBarController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 8/22/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vcs = tabBarController.viewControllers {
            for vc in vcs {
                if let nav = vc as? UINavigationController {
                    nav.popToRootViewController(animated: false)
                }
            }
        }
    }

}
