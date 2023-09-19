//
//  IAPManeger.swift
//  Thoughts
//
//  Created by Alexandr Bahno on 27.08.2023.
//

import Foundation
import Purchases

final class IAPManager {
    static let shared = IAPManager()
    
    private init() {}
    
    func isPremium() -> Bool {
        return false
    }
    
    func subscribe() {
        
    }
    
    func restorePurchase() {
        
    }
}
