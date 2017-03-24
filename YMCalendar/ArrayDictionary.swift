//
//  ArrayDictionary.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/22.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

public struct ArrayDictionary<Key, Value> where Key: Hashable, Key: Comparable, Value: Any {
    public typealias Dict = (Key, Value)
    
    public var dictArray: [Dict]
    
    init() {
        dictArray = []
    }
    
    // - MARK: subscript
    
    public subscript(index: Int) -> Dict {
        return dictArray[index]
    }
    
    // - MARK: variables
    
    public var count: Int {
        return dictArray.count
    }
    
    public func indexOf(key: Key) -> Int? {
        return dictArray.index(where: {$0.0 == key})
    }
    
    public var first: Dict? {
        return dictArray.first
    }
    
    public var last: Dict? {
        return dictArray.last
    }
    
    // - MARK: public
    
    public func value(forKey key: Key) -> Value? {
        guard let dict = dictArray.first(where: {$0.0 == key}) else {
            return nil
        }
        return dict.1
    }
    
    public func forEach(_ handler: (Key, Value) -> ()) {
        dictArray.forEach { handler($0.0, $0.1) }
    }
    
    // - MARK: mutating
    
    public mutating func setValue(_ value: Value, forKey key: Key) {
        if let index = indexOf(key: key) {
            dictArray[index].1 = value
        } else {
            dictArray.append((key, value))
        }
    }
    
    public mutating func removeValue(forKey key: Key) {
        if let index = indexOf(key: key) {
            dictArray.remove(at: index)
        }
    }
}
