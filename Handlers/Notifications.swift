//
//  Notifications.swift
//  SimpleNotifications
//
//  Created by Federico on 30/11/2021.
//

import Foundation
import UserNotifications
import UIKit
import AVFoundation

public enum NotificationType {
    case start
    case breathing(isInhale: Bool)
    case end
    
    var title: String {
        switch self {
        case .start: return "def digital_smoke():"
        case .breathing(let isInhale): return isInhale ? "def inhaling():" : "def exhaling():"
        case .end: return "def smoke_done():"
        }
    }
    
    var body: String {
        switch self {
        case .start: return "print(\"🚬\")"
        case .breathing(let isInhale): return isInhale ? "print(\"😮‍💨\")" : "print(\"💨\")"
        case .end: return "print(\"❌\")"
        }
    }
    
    var sound: UNNotificationSound {
        switch self {
        case .start, .breathing, .end:
            print("Attempting to load sound file...")
            if let path = Bundle.main.path(forResource: "rebound", ofType: "wav") {
                print("Found sound file at: \(path)")
            } else {
                print("Could not find sound file!")
            }
            return UNNotificationSound(named: UNNotificationSoundName("rebound.wav"))
        }
    }
}

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    @Published var isGranted = false
    private var timer: Timer?
    var breakCount = 0
    let maxBreaks = 7  // 7 breaks total
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.isGranted = true
                }
                print("✅ All permissions granted")
            } else {
                print("❌ Permissions denied: \(String(describing: error))")
            }
        }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m"
        } else {
            let hours = Int(seconds / 3600)
            let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
    
    func startHourlyBreakCycle() {
        guard breakCount < maxBreaks else { return }
        
        print("🔄 Starting break \(breakCount + 1) of \(maxBreaks)...")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Start notification - first break after 1 hour, others after 10s
        let startContent = UNMutableNotificationContent()
        startContent.title = "def digital_smoke():"
        startContent.body = "print(\"🚬\")"
        startContent.sound = UNNotificationSound.default
        
        let initialDelay = breakCount == 0 ? 3600.0 : 10.0  // 1 hour for first break, 10s for others
        let startTrigger = UNTimeIntervalNotificationTrigger(timeInterval: initialDelay, repeats: false)
        let startRequest = UNNotificationRequest(identifier: "start-\(breakCount)", content: startContent, trigger: startTrigger)
        UNUserNotificationCenter.current().add(startRequest)
        
        // Schedule breathing notifications - 30 cycles for 10 minutes
        for i in 0..<30 {
            let breathTime = initialDelay + 10.0 + Double(i * 20)  // Start 10s after start notification
            
            // Inhale
            let inhaleContent = UNMutableNotificationContent()
            inhaleContent.title = "def inhaling():"
            inhaleContent.body = "print(\"😮‍💨\")"
            inhaleContent.sound = UNNotificationSound.default
            
            let inhaleTrigger = UNTimeIntervalNotificationTrigger(timeInterval: breathTime, repeats: false)
            let inhaleRequest = UNNotificationRequest(identifier: "inhale-\(breakCount)-\(i)", content: inhaleContent, trigger: inhaleTrigger)
            UNUserNotificationCenter.current().add(inhaleRequest)
            
            // Exhale (10 seconds after inhale)
            let exhaleContent = UNMutableNotificationContent()
            exhaleContent.title = "def exhaling():"
            exhaleContent.body = "print(\"💨\")"
            exhaleContent.sound = UNNotificationSound.default
            
            let exhaleTrigger = UNTimeIntervalNotificationTrigger(timeInterval: breathTime + 10, repeats: false)
            let exhaleRequest = UNNotificationRequest(identifier: "exhale-\(breakCount)-\(i)", content: exhaleContent, trigger: exhaleTrigger)
            UNUserNotificationCenter.current().add(exhaleRequest)
        }
        
        // End notification
        let endContent = UNMutableNotificationContent()
        endContent.title = "def smoke_done():"
        endContent.body = "print(\"❌\")"
        endContent.sound = UNNotificationSound.default
        
        let endTrigger = UNTimeIntervalNotificationTrigger(timeInterval: initialDelay + 610, repeats: false)  // initial delay + 10m 10s
        let endRequest = UNNotificationRequest(identifier: "end-\(breakCount)", content: endContent, trigger: endTrigger)
        UNUserNotificationCenter.current().add(endRequest)
        
        let startTime = breakCount == 0 ? "1 hour" : "10 seconds"
        print("✅ Break \(breakCount + 1) scheduled:")
        print("   🎬 Start: +\(startTime)")
        print("   💨 First breath: +10s after start")
        print("   🫁 30 breathing cycles (20-second intervals)")
        print("   🏁 End: +10m 20s after start")
        
        // Schedule next break in 1 hour after this one ends
        breakCount += 1
        if breakCount < maxBreaks {
            let nextDelay = initialDelay + 3620  // initial delay + 10m 20s + 1 hour
            DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay) {
                self.startHourlyBreakCycle()
            }
        } else {
            print("🏁 Full workday scheduled!")
            print("   📅 7 breaks completed")
            print("   ⏰ 1 hour between breaks")
            print("   🫁 30 breathing cycles per break")
        }
    }
    
    func stopAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("⏹️ All notifications cancelled")
    }
    
    // Delegate method to handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
