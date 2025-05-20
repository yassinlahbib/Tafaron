//
//  Utilities.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import Foundation
import UIKit

final class Utilities  {
    
    static let shared = Utilities()
    private init() {}
    
    
        @MainActor
        func topViewController(controller: UIViewController? = nil) -> UIViewController? {
            
            // Trouver la bonne window active
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            
            //let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
            let controller = controller ?? keyWindow?.rootViewController
            
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
}
