//
//  ViewControllerHelper.swift
//  TARtest
//
//  Created by Mayer Lam on 2020/3/9.
//  Copyright © 2020 Mayer Lam. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    
    func showMsgBox(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMsgBox(
        _message: String,
        _title: String = "提示",
        acitons: [(title: String, style: UIAlertAction.Style, handler: ((_: UIAlertAction) -> ())?)] = [(title: "好的", .default, nil)]
    ) {
        let alert = createMsgBox(_message: _message, _title: _title, acitons: acitons)
        self.present(alert, animated: true, completion: nil)
    }
}

func createAction(_ title: String, _ style: UIAlertAction.Style, _ handler: ((_: UIAlertAction) -> ())?) -> (title: String, style: UIAlertAction.Style, handler: ((_: UIAlertAction) -> ())?) {
    return (title: title, style: style, handler: handler)
}

func createMsgBox(
    _message: String,
    _title: String,
    acitons: [(title: String, style: UIAlertAction.Style, handler: ((_: UIAlertAction) -> ())?)]
) -> UIAlertController {
    
    let alert = UIAlertController(title: _title, message: _message, preferredStyle: .alert)
    
    for action in acitons {
        let btn = UIAlertAction(title: action.title, style: action.style, handler: action.handler)
        alert.addAction(btn)
    }
    
    return alert
}
