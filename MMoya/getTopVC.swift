//
//  getTopVC.swift
//  TARtest
//
//  Created by Mayer Lam on 2020/3/9.
//  Copyright © 2020 Mayer Lam. All rights reserved.
//

import Foundation
import UIKit

 // MARK: - 查找顶层控制器、
 // 获取顶层控制器 根据window
func getTopVC() -> (UIViewController?) {
    
    var window = UIApplication.shared.keyWindow
    //是否为当前显示的window
    if window?.windowLevel != UIWindow.Level.normal {
        
        let windows = UIApplication.shared.windows
        
        for windowTemp in windows {
        
            if windowTemp.windowLevel == UIWindow.Level.normal {
                window = windowTemp
                break
            }
        }
    }
    
    let vc = window?.rootViewController
    return getTopVC(withCurrentVC: vc)
}

  ///根据控制器获取 顶层控制器
func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {
    
    if VC == nil {
        return nil
    }
    
    if let presentVC = VC?.presentedViewController {
        //modal出来的 控制器
        return getTopVC(withCurrentVC: presentVC)
    } else if let tabVC = VC as? UITabBarController {
    
    // tabBar 的跟控制器
    if let selectVC = tabVC.selectedViewController {
      return getTopVC(withCurrentVC: selectVC)
    }
        
    return nil
        
} else if let naiVC = VC as? UINavigationController {
        // 控制器是 nav
        return getTopVC(withCurrentVC:naiVC.visibleViewController)
    } else {
        // 返回顶控制器
        return VC
    }
}
