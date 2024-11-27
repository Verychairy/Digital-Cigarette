import Foundation
import UserNotifications

class NotificationHandler {
    func startHourlyBreakCycle() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Break Time"
        content.body = "Time for your hourly break"
        content.sound = .default
        
        // Create hourly trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "hourlyBreak",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func stopAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 