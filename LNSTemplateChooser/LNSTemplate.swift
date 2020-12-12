//
//  LNSTemplate.swift
//  LNSTemplateChooser
//
//  Created by Mark Alldritt on 2020-07-12.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import Foundation


class LNSTemplate {
    let fileURL: URL
    let name: String
    
    init(url fileURL: URL, name: String) {
        self.fileURL = fileURL
        self.name = name
    }
}
