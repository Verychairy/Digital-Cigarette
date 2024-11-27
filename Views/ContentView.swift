//
//  ContentView.swift
//  SimpleNotifications
//
//  Created by Federico on 30/11/2021.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    let notify = NotificationHandler()
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack(spacing: 40) {
                    Text("-.. .. --. .. - .- .-.. / -.-. .. --. .- .-. . - - .")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    
                    VStack {
                        Button(action: {
                            handleStartStop()
                        }) {
                            Text(isActive ? "Stop" : "Start")
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(22)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    func handleStartStop() {
        if !isActive {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    DispatchQueue.main.async {
                        isActive = true
                        notify.startHourlyBreakCycle()
                    }
                }
            }
        } else {
            isActive = false
            notify.stopAllNotifications()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
