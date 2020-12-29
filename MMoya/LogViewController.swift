//
//  LogViewController.swift
//
//  Created by Mayer Lam on 2019/12/23.
//  Copyright © 2019 shootProj. All rights reserved.
//

import Foundation
import UIKit

class LogViewController: UIViewController {
    
    lazy var textLabel = UILabel()
    
    lazy var logString: String = ""
    
    convenience init(log: String) {
        self.init()
        logString = log
        textLabel.text = log
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "错误日志"
        self.view.addSubview(textLabel)
        textLabel.frame = self.view.frame
        textLabel.textAlignment = .left
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.numberOfLines = 0
        self.view.backgroundColor = .white
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

