//
//  IndexableDictionary.swift
//  IndexableDictionary
//
//  Created by Yuma Matsune on 2017/04/26.
//  Copyright © 2017年 matsune. All rights reserved.
//

/**
 
 IndexableDictionary is a structure which combines both features of `Array` and `Dictionary`.
 It can hold `key` and `value` pairs and access to them like dictionary.
 And it has indices of key-value pairs like array, so you can get values by
 array methods and subscripts.
 
 https://github.com/matsune/IndexableDictionary
 
 */
public struct IndexableDictionary<Key: Hashable, Value>: RandomAccessCollection, ExpressibleByArrayLiteral, RangeReplaceableCollection, BidirectionalCollection {
    
    // MARK: - Type Aliases
    
    public typealias Element = (key: Key, value: Value)
    
    public typealias SubSequence = IndexableDictionary
    
    public typealias Index = Int
    
    public typealias Indices = CountableRange<Int>
    
    fileprivate var _elements: [Element]
    
    // MARK: - Initializer
    
    public init() {
        _elements = []
    }
    
    public init(arrayLiteral elements: Element...) {
        _elements = elements
    }
    
    public init(_ elements: [Element]) {
        _elements = elements
    }
    
    // MARK: - Subscript
    
    public subscript(position: Int) -> Element {
        get { return _elements[position] }
        set { _elements[position] = newValue }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        let _array = (bounds.lowerBound..<bounds.upperBound).map { index -> Element in
            return self[index]
        }
        return IndexableDictionary(_array)
    }
    
    // MARK: - Indices
    
    public var startIndex: Index { return _elements.startIndex }
    
    public var endIndex  : Index { return _elements.endIndex }
    
    public func index(forKey key: Key) -> Index? {
        return _elements.index(where: {$0.0 == key})
    }
    
    // MARK: - Range Replace
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, C.Iterator.Element == IndexableDictionary.Iterator.Element {
        _elements.replaceSubrange(subrange, with: newElements)
    }
    
    // MARK: - Dictionary property
    
    public var keys: LazyMapCollection<IndexableDictionary, Key> { return lazy.map {$0.key} }
    
    public var values: LazyMapCollection<IndexableDictionary, Value> { return lazy.map {$0.value} }
    
    public func value(forKey key: Key) -> Value? {
        return _elements.first(where: {$0.key == key})?.value
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let index = index(forKey: key) else { return nil }
        return remove(at: index).value
    }
    
    @discardableResult
    public mutating func updateValue(_ newValue: Value, forKey key: Key) -> Value? {
        guard let oldValue = value(forKey: key), let index = index(forKey: key) else {
            append((key, newValue))
            return nil
        }
        self[index].value = newValue
        return oldValue
    }
}

// MARK: - Operator

extension IndexableDictionary where Value: Equatable {
    public static func ==(lhs: IndexableDictionary, rhs: IndexableDictionary) -> Bool {
        return lhs.keys.elementsEqual(rhs.keys) && lhs.values.elementsEqual(rhs.values)
    }
}
