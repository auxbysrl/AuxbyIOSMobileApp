//
//  AppFileManager.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation

class AppFileManager {
    
    /// Create a path to document directory for a given name; returns the full string file path
    class func path(name: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = NSURL(fileURLWithPath: path)
        return url.appendingPathComponent(name)!.path
    }
    
    /// Check if a specific file exist in the documents folder
    class func fileExist(withPath: String) -> Bool {
        // print(listFilesFromDocumentsFolder())
        FileManager.default.fileExists(atPath: path(name: withPath))
    }
    
    /// Remove o specific file from documents folder (if file exist)
    class func removeFile(withName: String, success: (() -> Void)? = nil) {
        let path = self.path(name: withName)
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
            success?()
        }
    }
    
    /// View all content from document directory for debugging purpose
    class func listFilesFromDocumentsFolder() -> [String] {
        let fileMngr = FileManager.default
        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        return (try? fileMngr.contentsOfDirectory(atPath: docs)) ?? []
    }
    
    class func deleteAllDownloadedFiles() {
        for pathName in listFilesFromDocumentsFolder() {
            removeFile(withName: pathName)
        }
        print("All saved files deleted ✅")
    }
}
