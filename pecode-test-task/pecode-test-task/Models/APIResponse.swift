//
//  APIResponse.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 04.10.2023.
//

import Foundation

struct APIResponse: Codable {
    let articles: [Article]
}
struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let author: String?
    
}
struct Source: Codable {
    let name: String
}
