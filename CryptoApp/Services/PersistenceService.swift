//
//  PersistenceService.swift
//  CryptoApp
//
//  Created by Patricia Costin on 14.08.2024.
//

import Foundation
import RealmSwift

final class PersistenceService {
    private lazy var realm: Realm? = {
        try? Realm()
    }()
    
    public func addValuesToCoin(code: String, value: Double) {
        guard let realm = realm else { return }
        
        do {
            if let existingCoin = realm.objects(PersistentCoin.self).filter("code == %@", code).first {
                try realm.write {
                    existingCoin.values.append(value)
                }
            } else {
                let newCoin = PersistentCoin()
                newCoin.code = code
                newCoin.values.append(value)
                try realm.write {
                    realm.add(newCoin)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func fetchAllCoins() -> [PersistentCoin]? {
        guard let realm = realm else { return nil }
        let results = realm.objects(PersistentCoin.self)
        return Array(results)
    }
}
