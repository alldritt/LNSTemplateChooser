//
//  LNSBarButtonItem.swift
//  LNSShared
//
//  Created by Mark Alldritt on 2018-05-28.
//  Copyright © 2018 Late Night Software Ltd. All rights reserved.
//

import UIKit

class LNSBarButtonItem: UIBarButtonItem {
    private var actionHandler: ((LNSBarButtonItem) -> Void)?
    
    public convenience init(barButtonSystemItem: UIBarButtonItem.SystemItem, actionHandler: ((LNSBarButtonItem) -> Void)?) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: #selector(barButtonItemPressed(_:)))
        self.target = self
        self.actionHandler = actionHandler
    }
    
     public convenience init(title: String?, style: UIBarButtonItem.Style, actionHandler: ((LNSBarButtonItem) -> Void)?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed(_:)))
        self.target = self
        self.actionHandler = actionHandler
    }
    
     public convenience init(image: UIImage?, style: UIBarButtonItem.Style, actionHandler: ((LNSBarButtonItem) -> Void)?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed(_:)))
        self.target = self
        self.actionHandler = actionHandler
    }
    
    @objc
    private func barButtonItemPressed(_ sender: UIBarButtonItem) {
        actionHandler?(self)
    }

}
