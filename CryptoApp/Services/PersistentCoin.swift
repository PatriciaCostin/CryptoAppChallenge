//
//  RealmModel.swift
//  CryptoApp
//
//  Created by Patricia Costin on 14.08.2024.
//

import Foundation
import RealmSwift

class PersistentCoin: Object {
    @Persisted var code: String
    @Persisted var values: List<Double?>
}
