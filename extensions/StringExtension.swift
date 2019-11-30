//
//  StringExtension.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/30/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    func toResult() -> PredictionResult? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(PredictionResult.self, from: data)
            return result
        } catch {
            return nil
        }
//        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
