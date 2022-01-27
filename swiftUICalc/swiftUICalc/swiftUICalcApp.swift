//
//  swiftUICalcApp.swift
//  swiftUICalc
//
//  Created by Young Soo Hwang on 2022/01/27.
//

import SwiftUI

@main
struct swiftUICalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(GlobalEnvironment())
        }
    }
}
