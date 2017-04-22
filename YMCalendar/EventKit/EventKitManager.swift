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

final class EventKitManager {
    typealias EventSaveCompletionBlockType = (Bool) -> Void
    
    var eventStore: EKEventStore
    
    init(eventStore: EKEventStore?=nil) {
        if let eventStore = eventStore {
            self.eventStore = eventStore
        } else {
            self.eventStore = EKEventStore()
        }
    }
    
    var savedEvent: EKEvent?
    
    var saveCompletion: EventSaveCompletionBlockType?
    
    var accessGranted: Bool = false
    
    func checkEventStoreAccessForCalendar(completion: EventSaveCompletionBlockType?) {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            accessGrantedForCalendar()
            completion?(true)
        case .notDetermined:
            requestCalendarAccess(completion: completion)
        case .denied, .restricted:
            accessDeniedForCalendar()
            completion?(false)
        }
    }
    
    func requestCalendarAccess(completion: EventSaveCompletionBlockType?) {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            if granted {
                self?.accessGrantedForCalendar()
                completion?(true)
            }
        }
    }
    
    func accessGrantedForCalendar() {
        accessGranted = true
    }
    
    func accessDeniedForCalendar() {
        print("Access to the calendar was not authorized.")
    }
    
    func saveEvent(_ event: EKEvent, completion: EventSaveCompletionBlockType?) {
        if event.hasRecurrenceRules {
            savedEvent = event
            saveCompletion = completion
        } else {
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch {
                print(error)
                return
            }
            completion?(true)
            saveCompletion = nil
        }
    }
}
