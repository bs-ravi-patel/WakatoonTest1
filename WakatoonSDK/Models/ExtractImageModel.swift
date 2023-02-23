//
//  ExtractImageModel.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 21/12/22.
//

import Foundation


struct ExtractImageModal: Codable {
    
    let extractionSucceeded: Bool?
    let extractedArtworkImageUrl: String?
    let photoId: String?
    
}
struct CloudFunctionResponseModal : Codable {
    let statusCode: Int?
    let body: CloudFunctionBody?
}
struct CloudFunctionBody: Codable {
    let shape_found: Bool?
    let output_file_path: String?
    let request_id: String?
}
