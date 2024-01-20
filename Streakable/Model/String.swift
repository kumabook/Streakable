//
//  String.swift
//  Reminder
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import Foundation
import SwiftUI

extension String {
    var asDayText: Text {
        return Text(NSLocalizedString("Day.\(self)", comment: ""))
    }
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
