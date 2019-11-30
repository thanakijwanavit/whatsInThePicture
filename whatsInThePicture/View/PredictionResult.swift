//
//  result.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/30/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import Foundation
class PredictionResult: Codable{
    let result: String
    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
}


//\"\\\"{\\\\\\\"result\\\\\\\": \\\\\\\"promontory, headland, head, foreland\\\\\\\"}\\\"\"
