//
//  JumboStructs.swift
//  JumboApp
//
//  Created by Nicholas Reeder on 1/27/20.
//  Copyright © 2020 Nicholas Reeder. All rights reserved.
//

import Foundation

struct SectionData {
    var id: String
    var objects: [Message]
}

struct Message: Codable {
    var id: String
    var message: String
    var progress: Double = 0.0
    var state: String? = nil
}
