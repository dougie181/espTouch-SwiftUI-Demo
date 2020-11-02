//
//  esp32SmartConfigDemoApp.swift
//  esp32SmartConfigDemo
//
//  Created by Doug Inman on 30/10/20.
//

import SwiftUI
//import ESPTouchSwift

@main
struct esp32SmartConfigDemoApp: App {
    let espTouch = ESPTouchManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: espTouch)
        }
    }
}
