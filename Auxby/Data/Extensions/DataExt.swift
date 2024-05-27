//
//  DataExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation

extension Data {
    /// Try to extract the JSON string from data (that supposedly contains a raw JSON string) as pretty printed
    var asJsonPrettyPrinted: String? {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return String(decoding: jsonData, as: UTF8.self)
        }
        return nil
    }
    
    /// Convert Data  to its corresponding Int value.
    var asInt: Int {
        var intValue: Int = 0
        (self as NSData).getBytes(&intValue, length: MemoryLayout<Int>.size)
        return Int(intValue)
    }
    
    /// Convert Data (format Int16) to its corresponding Int value.
    /// Used for the 360 Data Bar devices
    var asInt16: Int {
        var intValue: Int16 = 0
        (self as NSData).getBytes(&intValue, length: MemoryLayout<Int16>.size)
        return Int(intValue)
    }
    
    /// Convert Data (format Int8) to its corresponding Int value.
    /// Used for the Hamstring Solo devices
    var asInt8: Int {
        var intValue: Int8 = 0
        (self as NSData).getBytes(&intValue, length: MemoryLayout<Int8>.size)
        return Int(intValue)
    }
    
    /// The data received from the Hamstring Solo NDSports devices is in Big-endian format. The Apple uses Little-Endian mode.
    /// Use this method to covert data from Big-endian to Little-Endian mode.
    func swapUInt16Data() -> Data {
        var mdata = self // make a mutable copy
        let count = count / MemoryLayout<UInt16>.size
        mdata.withUnsafeMutableBytes { i16ptr in
            let bufferPointer = i16ptr.bindMemory(to: UInt16.self)
            for i in 0 ..< count {
                bufferPointer[i] = bufferPointer[i].byteSwapped
            }
        }
        return mdata
    }
}
