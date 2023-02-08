//
//  FileManager+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 27/12/22.
//

import Foundation


extension FileManager {
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
