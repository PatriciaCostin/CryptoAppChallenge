//
//  CryptoViewModel.swift
//  CryptoApp
//
//  Created by Patricia Costin on 13.08.2024.
//

import Foundation
import CryptoAPI
import UIKit
import OSLog

@MainActor
final class CryptoViewModel: ObservableObject {
    @Published var coins: [CoinModel] = []
    private var persistentCoins: [PersistentCoin] = [] // Used for populating history values in coins: [CoinModel]
    private let logger = Logger()
    private lazy var cryptoAPI: Crypto = {
        return Crypto(delegate: self)
    }()
    private var persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    public func launchCryptoAPI() {
        let result = cryptoAPI.connect()
        switch result {
        case .success(let isConnected):
            if isConnected {
                connectedAction()
            } else {
                logger.warning("Crypto API not fully connected")
            }
        case .failure(let error):
            logger.error("Crypto API failed to connect, error: \(error)")
            switch error as? CryptoError {
            case .connectAfter(let date):
                scheduleFunctionCall(for: date)
            default:
                logger.error("Could not handle error: \(error)")
            }
        }
    }
    
    public func disconnectAPI() {
        cryptoAPI.disconnect()
    }
    
    private func connectedAction() {
        logger.debug("Crypto API connected")
        coins = []
        persistentCoins = []
        let rawCoins = cryptoAPI.getAllCoins()
        for coin in rawCoins {
            persistenceService.addValuesToCoin(code: coin.code, value: coin.price)
        }
        persistentCoins = persistenceService.fetchAllCoins() ?? []
        populateCoins(rawCoins: rawCoins)
    }
    
    private func scheduleFunctionCall(for targetDate: Date) {
        let currentDate = Date()
        let timeInterval = targetDate.timeIntervalSince(currentDate)

        if timeInterval > 0 {
            logger.debug("Will reconnect in \(timeInterval) seconds.")
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                self.launchCryptoAPI()
            }
        } else {
            logger.debug("The target date is in the past. No need to schedule.")
            launchCryptoAPI()
        }
    }
        
    private func populateCoins(rawCoins: [Coin]) {
        for coin in rawCoins {
            let index = persistentCoins.firstIndex(where: { $0.code == coin.code})
            guard let index = index else { return }
            let historyOfValues = Array(persistentCoins[index].values).compactMap{ $0 }
            
            let processedCoin = CoinModel(
                name: coin.name,
                code: coin.code,
                imageUrl: coin.imageUrl,
                values: historyOfValues,
                currentValue: coin.price
            )
            coins.append(processedCoin)
        }
    }
}

extension CryptoViewModel: CryptoDelegate {
    func cryptoAPIDidConnect() {
        logger.info("CryptoAPI did connect")
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: CryptoAPI.Coin) {
        Task {
            if let firstIndexOfCoin = self.coins.firstIndex(where: { $0.code == coin.code }) {
                self.coins[firstIndexOfCoin].values?.append(coin.price)
                self.coins[firstIndexOfCoin].currentValue = coin.price
                
                persistenceService.addValuesToCoin(code: coin.code, value: coin.price)
            }
            logger.debug("Updated \(coin.name) with \(coin.price)")
        }
    }
    
    func cryptoAPIDidDisconnect() {
        logger.info("CryptoAPI did disconnect")
        if UIApplication.shared.applicationState == .active {
            logger.info("Trying to reconect to CryptoAPI")
            launchCryptoAPI()
        }
    }
}
