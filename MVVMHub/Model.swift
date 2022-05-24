//
//  Model.swift
//  MVVMHub
//
//  Created by Yusuke Ohashi on 2022/05/24.
//

import Foundation

struct Repo: Codable {
    let id: Int
    let name: String
}

struct BasicError: Codable {
    let message: String?
    let documentationUrl: String?
    let url: String?
    let status: String?
    
    private enum CodingKeys: String, CodingKey {
        case message
        case documentationUrl = "documentation_url"
        case url
        case status
    }
}

struct ValidationError: Codable {
    let message: String?    
}

extension Repo: Hashable, Identifiable {}
