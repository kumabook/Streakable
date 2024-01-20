//
//  Array.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/04.
//

import Foundation

extension Array where Element: Hashable {
    public var unique: [Element] {
        var set = Set<Element>()
        return self.reduce(into: []) { acc, element in
            guard !set.contains(element) else { return }
            set.insert(element)
            acc.append(element)
        }
    }
}

extension Sequence {
    public func uniqueBy<T: Hashable>(_ handler: (_ element: Self.Iterator.Element) -> T) -> [Self.Iterator.Element] {
        var keys = Set<T>()
        return self.filter { element -> Bool in
            let key = handler(element)
            if !keys.contains(key) {
                keys.insert(key)
                return true
            }
            return false
        }
    }
}
