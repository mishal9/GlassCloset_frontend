//
//  Item.swift
//  GlassCloset
//
//  Created by Mishal on 4/26/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
