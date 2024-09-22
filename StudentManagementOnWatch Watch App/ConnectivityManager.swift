//
//  ConnectivityManager.swift
//  StudentManagementOnWatch Watch App
//
//  Created by Hydan on 22/9/24.
//

import Foundation
import WatchConnectivity

class ConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    var onReceiveStudents: (([Student]) -> Void)?
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    func session(_ session: WCSession, activationDidFailWith error: Error) {
        print("Session activation failed: \(error.localizedDescription)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let data = message["students"] as? Data {
            do {
                let decodedStudents = try JSONDecoder().decode([Student].self, from: data)
                onReceiveStudents?(decodedStudents)
            } catch {
                print("Failed to decode students: \(error)")
            }
        }
    }
    
    // New method for handling session activation completion
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Activation completed with error: \(error.localizedDescription)")
        } else {
            print("Session activated with state: \(activationState)")
        }
    }
}
