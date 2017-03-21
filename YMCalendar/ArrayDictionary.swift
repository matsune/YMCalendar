//
//  ArrayDictionary.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
struct ArrayDictionary<Key, Value> where Key: Hashable, Key: Comparable, Value: Any {
    typealias Dict = (Key, Value)
    
    var dictArray: [Dict]
    
    init() {
        dictArray = []
    }
    
    // - MARK: subscript
    
    subscript(index: Int) -> Dict {
        return dictArray[index]
    }
    
    // - MARK: variables
    
    var count: Int {
        return dictArray.count
    }
    
    func indexOf(key: Key) -> Int? {
        return dictArray.index(where: {$0.0 == key})
    }
    
    var first: Dict? {
        return dictArray.first
    }
    
    var last: Dict? {
        return dictArray.last
    }
    
    // - MARK: public
    
    func value(forKey key: Key) -> Value? {
        guard let dict = dictArray.first(where: {$0.0 == key}) else {
            return nil
        }
        return dict.1
    }
    
    func forEach(_ handler: (Key, Value) -> ()) {
        dictArray.forEach { handler($0.0, $0.1) }
    }
    
    
    // - MARK: mutating
    
    mutating func setValue(_ value: Value, forKey key: Key) {
        if let index = indexOf(key: key) {
            dictArray[index].1 = value
        } else {
            dictArray.append((key, value))
        }
    }
    
    mutating func removeValue(forKey key: Key) {
        if let index = indexOf(key: key) {
            dictArray.remove(at: index)
        }
    }
    
}
