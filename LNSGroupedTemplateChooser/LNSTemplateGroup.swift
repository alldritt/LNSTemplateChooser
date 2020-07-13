//
//  LNSTemplateGroup.swift
//  LNSTemplateChooser
//
//  Created by Mark Alldritt on 2020-07-12.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import Foundation


class LNSTemplateGroup {
    let name: String
    let templates: [LNSTemplate]
    
    init(name: String, templates: [LNSTemplate]) {
        self.name = name
        self.templates = templates
    }
}
