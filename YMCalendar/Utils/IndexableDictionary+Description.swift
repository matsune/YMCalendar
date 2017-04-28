//
//  IndexableDictionary+Description.swift
//  IndexableDictionary
//
//  Created by Yuma Matsune on 2017/04/28.
//  Copyright © 2017年 matsune. All rights reserved.
//

/// - MARK: CustomStringConvertibles

extension IndexableDictionary: CustomStringConvertible {
    public var description: String {
        return makeDescription(debug: false)
    }
}

extension IndexableDictionary: CustomDebugStringConvertible {
    public var debugDescription: String {
        return makeDescription(debug: true)
    }
}

extension IndexableDictionary {
    fileprivate func makeDescription(debug: Bool) -> String {
        if isEmpty { return "[:]" }
        
        let printFunction: (Any, inout String) -> () = {
            if debug {
                return { debugPrint($0, separator: "", terminator: "", to: &$1) }
            } else {
                return { print($0, separator: "", terminator: "", to: &$1) }
            }
        }()
        
        let descriptionForItem: (Any) -> String = { item in
            var description = ""
            printFunction(item, &description)
            return description
        }
        
        let bodyComponents = map { element in
            return descriptionForItem(element.key) + ": " + descriptionForItem(element.value)
        }
        
        let body = bodyComponents.joined(separator: ", ")
        
        return "[\(body)]"
    }
}
