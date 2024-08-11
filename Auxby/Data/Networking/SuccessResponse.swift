//
//  SuccessResponse.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation

/**
 Used to store success responses
 
 ✅ SUCCESS RESPONSE ✅
 {
    "message" : "Player successfully added"
 }
 */
struct SuccessResponse: Decodable {
    let message: String
}

struct SuccessResponseBool: Codable {
    let successful: Bool
}

struct EmptyResponse: Decodable {
}
