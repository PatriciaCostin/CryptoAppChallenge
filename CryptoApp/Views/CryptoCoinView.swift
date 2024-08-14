//
//  CryptoCoinView.swift
//  CryptoApp
//
//  Created by Patricia Costin on 14.08.2024.
//

import SwiftUI

struct CryptoCoinView: View {
    var coin: CoinModel
    @State private var viewBackgroundColor: UIColor = .clear
    @State private var currentValueBackgroundColor: UIColor = .clear
    @State private var currentValueForegroundColor: UIColor = .black
    var body: some View {
        HStack {
            // MARK: - Coin Icon
            VStack {
                AsyncImage(url: URL(string: coin.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .padding(.top, 10)
                } placeholder: {
                    ProgressView()
                }
                Spacer()
            }
            VStack {
                // MARK: - First row of views
                HStack {
                    // Coin name
                    Text(coin.name)
                        .foregroundColor(.black)
                    
                    // Coin code
                    Text(coin.code)
                        .foregroundColor(.gray.opacity(0.7))
                    Spacer()
                    
                    // Current value
                    HStack {
                        Spacer()
                        Text("$ \(String(format: stringFormat(value: coin.currentValue), coin.currentValue))")
                            .foregroundColor(Color(currentValueForegroundColor))
                            .padding(5)
                    }
                    .frame(width: 110, height: 35)
                    .background(Color(currentValueBackgroundColor))
                    .cornerRadius(5)
                    .onChange(of: coin.currentValue) {
                        currentValueBackground(coin)
                    }
                }
                
                // MARK: - Second row of views
                HStack(spacing: 0) {
                    
                    // Min value
                    HStack(spacing: 3) {
                        Text("min:")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.system(size: 10))
                        Text("$ \(String(format: stringFormat(value: coin.values?.min()), coin.values?.min() ?? 0.0))")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .frame(width: 120)
                    
                    // Max value
                    HStack(spacing: 3) {
                        Text("max:")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.system(size: 10))
                        Text("$ \(String(format: stringFormat(value: coin.values?.max()), coin.values?.max() ?? 0.0))")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                        Spacer()
                    }
                    Spacer()
                }
            }
            .padding(5)
            .background(Color(viewBackgroundColor))
            .cornerRadius(5)
        }
    }
    
    // MARK: - Helper functions
    func currentValueBackground(_ coin: CoinModel) {
        setViewBackground()
        
        if let maxValue = coin.values?.max(), coin.currentValue < maxValue {
            currentValueBackgroundColor = .deepRed
            currentValueForegroundColor = .white
        } else {
            currentValueBackgroundColor = .deepGreen
            currentValueForegroundColor = .white
        }
    }
    
    func setViewBackground() {
        withAnimation {
            viewBackgroundColor = .gray.withAlphaComponent(0.2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            withAnimation {
                viewBackgroundColor = .clear
            }
        }
    }
    
    func stringFormat(value: Double?) -> String {
        guard let value = value else { return "" }
        if value > 1 {
            return "%.2f"
        } else {
            return "%.6f"
        }
    }
}
