//
//  ReusableObjectQueue.swift
//  YMCalendar
//
//  Created by Yuma Matsune on 2017/04/28.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation

final internal class ReusableObjectQueue {
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
    
    func dequeueReusableObjectWithIdentifier(_ identifier: String) -> T? {
        if let object = reusableObjects[identifier] {
            reusableObjects.removeValue(forKey: identifier)
            object.prepareForReuse()
            return object
        } else {
            guard let anyClass = objectClasses[identifier] else {
                fatalError("\(identifier) is not registered.")
            }
            let object = anyClass.init()
            totalCreated += 1
            object.reuseIdentifier = identifier
            return object
        }
    }
    
    func removeAll() {
        reusableObjects.removeAll()
    }
}
