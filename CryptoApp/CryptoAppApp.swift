//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Patricia Costin on 13.08.2024.
//

import SwiftUI

@main
struct CryptoAppApp: App {
    @StateObject var viewModel: CryptoViewModel
    @Environment (\.scenePhase) var scenePhase
    
    init() {
        let persistenceService = PersistenceService()
        _viewModel = StateObject(wrappedValue: CryptoViewModel(persistenceService: persistenceService))
    }
    
    var body: some Scene {
        WindowGroup {
            CryptoScreen(viewModel: viewModel)
                .onChange(of: scenePhase) { oldValue, newValue in
                    switch newValue {
                    case .active:
                        viewModel.launchCryptoAPI()
                    case .background:
                        viewModel.disconnectAPI()
                    case .inactive:
                        viewModel.disconnectAPI()
                    @unknown default:
                        break
                    }
                }
        }
    }
}
