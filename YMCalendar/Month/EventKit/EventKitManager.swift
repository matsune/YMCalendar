//
//  EventKitManager.swift
//  YMCalendarDemo
//
//  Created by Yuma Matsune on 2017/03/17.
//  Copyright © 2017年 Yuma Matsune. All rights reserved.
//

import Foundation
import UIKit
import EventKit

final public class EventKitManager {
    public typealias EventSaveCompletionBlockType = (_ accessGranted: Bool) -> Void
    
    public var eventStore: EKEventStore
    
    public init(eventStore: EKEventStore?=nil) {
        if let eventStore = eventStore {
            self.eventStore = eventStore
        } else {
            self.eventStore = EKEventStore()
        }
    }
    
    public var isGranted: Bool = false
    
    public func checkEventStoreAccessForCalendar(completion: EventSaveCompletionBlockType?) {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            isGranted = true
            completion?(isGranted)
        case .notDetermined:
            requestCalendarAccess(completion: completion)
        case .denied, .restricted:
            print("Permition to access the calendar is denied.")
            isGranted = false
            completion?(isGranted)
        }
    }
    
    private func requestCalendarAccess(completion: EventSaveCompletionBlockType?) {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            self?.isGranted = granted
            completion?(granted)
        }
    }
}
