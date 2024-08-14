//
//  ContentView.swift
//  CryptoApp
//
//  Created by Patricia Costin on 13.08.2024.
//

import SwiftUI

struct CryptoScreen: View {
    @ObservedObject var viewModel: CryptoViewModel
    
    var body: some View {
        
        // MARK: - Content
        NavigationView {
            List {
                ForEach(viewModel.coins, id: \.code) { coin in
                    CryptoCoinView(coin: coin)
                }
            }
            .navigationTitle("Market")
        }
        .background(.white)
    }
}

