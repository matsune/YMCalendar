//
//  ReusableObject.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/03/07.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

public protocol ReusableObject: class {
    init()
    var reuseIdentifier: String {get set}
    
    func prepareForReuse()
}


final class ReusableObjectQueue {
    typealias T = ReusableObject
    
    var reusableObjects: [String : T] = [:]
    
    var objectClasses: [String : T.Type] = [:]
    
    var totalCreated = 0
    
    var count: Int {
        return reusableObjects.count
    }
    
    func registerClass(_ objectClass: T.Type?, forObjectWithReuseIdentifier identifier: String) {
        if let objClass = objectClass {
            objectClasses[identifier] = objClass
        } else {
            objectClasses.removeValue(forKey: identifier)
            reusableObjects.removeValue(forKey: identifier)
        }
    }
    
    func enqueueReusableObject(_ object: T) {
        reusableObjects[object.reuseIdentifier] = object
    }
    
    func dequeueReusableObjectWithIdentifier<T: ReusableObject>(_ identifier: String) -> T? {
        if let object = reusableObjects[identifier] as? T {
            reusableObjects.removeValue(forKey: identifier)
            object.prepareForReuse()
            return object
        } else {
            guard let anyClass = objectClasses[identifier] else {
                fatalError("\(identifier) is not registered.")
            }
            if anyClass is T.Type {
                totalCreated += 1
                let object = T()
                object.reuseIdentifier = identifier
                return object
            }
            fatalError("identifier \"\(identifier)\" is registered as \(anyClass)")
        }
    }
    
    func removeAll() {
        reusableObjects.removeAll()
    }
}
