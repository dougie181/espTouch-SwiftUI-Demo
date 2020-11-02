//
//  ESPTouch.swift
//  esp32SmartConfigDemo
//
//  Created by Doug Inman on 30/10/20.
//

import Foundation
import EspressifTouchSDK

enum SmartConfigState {
    case ready
    case inProgress
    case failed
    case completed
}

class ESPTouchManager : ObservableObject {
    @Published var manager = ESPTouch()
    var ssid: String?
    var bssid: String?
    var message: String = ""
    var state: SmartConfigState
    
    init() {
        self.state = .ready
        bssid = nil
        ssid = try? manager.currentWiFiSSID()
    }
    
    init(state : SmartConfigState) {
        self.state = state
        bssid = nil
        ssid = try? manager.currentWiFiSSID()
    }
    
    func restart() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        ssid = try? manager.currentWiFiSSID()
        print("ssid: \(String(ssid ?? "unknown"))")
        state = .ready
        message = ""
        
    }
    
    func cancel() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        state = .ready
        message = ""
        manager.cancel()
    }
    
    func performSmartConfig(password: String) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        state = .inProgress
        
        manager.smartConfig(password: password) { result in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            switch result {
            case .success(let model):
                self.state = .completed
                self.bssid = model.bssid
                print(String(model.bssid))
                self.message = "Successly updated \(model.bssid!)."
            case .failure(let error):
                self.state = .failed
                switch error {
                case .noSSID:
                    self.message = "Failed: No SSID found."
                    print("noSSID")
                case .timeout:
                    self.message = "Failed: Timeout occured."
                    print("timeout")
                }
            }
        }
    }
}
