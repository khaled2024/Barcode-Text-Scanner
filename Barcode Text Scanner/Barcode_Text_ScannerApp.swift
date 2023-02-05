//
//  Barcode_Text_ScannerApp.swift
//  Barcode Text Scanner
//
//  Created by KhaleD HuSsien on 05/02/2023.
//

import SwiftUI

@main
struct Barcode_Text_ScannerApp: App {
    @StateObject private var vm = AppViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task {
                    // for the firest time launch the app
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}
