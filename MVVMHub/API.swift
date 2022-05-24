//
//  API.swift
//  MVVMHub
//
//  Created by Yusuke Ohashi on 2022/05/24.
//

import Foundation

enum GithubError: Error {
    case basicError(BasicError)
    case validationError(ValidationError)
    case overRateLimit(rateLimit: String, resetData: Date)
    case invalidHTTPHeader
}

struct API {
    let endpoint = "https://api.github.com/"
    
    func getRepos(for userName: String) async throws -> [Repo] {
        let path = "/users/\(userName)/repos"
        let headers = ["Accept": "application/vnd.github.v3+json"]
        
        var urlComps = URLComponents()
        urlComps.scheme = "https"
        urlComps.host = "api.github.com"
        urlComps.path = path
        
        urlComps.queryItems = [
            URLQueryItem(name: "sort", value: "pushed"),
            URLQueryItem(name: "direction", value: "desc")
            ]
        
        guard let url = urlComps.url else {
            throw URLError(.badURL)
        }
                
        var request = URLRequest(url: url)
        for (k,v) in headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try verify(data: data, response: response)
        
        let repoResponse = try JSONDecoder().decode([Repo].self, from: data)
        return repoResponse
    }
    
    private func verify(data: Data, response: URLResponse) throws {
        
        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if  let rateLimit = urlResponse.value(forHTTPHeaderField: "x-ratelimit-limit"),
            let rateLimitRemaining = urlResponse.value(forHTTPHeaderField: "x-ratelimit-remaining"),
            let rateLimitResetDate = urlResponse.value(forHTTPHeaderField: "x-ratelimit-reset") {
                        
            if rateLimitRemaining == "0",
               let epochTime = TimeInterval(rateLimitResetDate) {
                let resetDate = Date(timeIntervalSince1970: epochTime)
                throw GithubError.overRateLimit(rateLimit: "\(rateLimitRemaining)/\(rateLimit)", resetData: resetDate)
            }
        } else {
            throw GithubError.invalidHTTPHeader
        }
        
        if urlResponse.statusCode != 200 {
            if urlResponse.statusCode == 422 {
                let validationError = try JSONDecoder().decode(ValidationError.self, from: data)
                throw GithubError.validationError(validationError)
            }
            
            let basicError = try JSONDecoder().decode(BasicError.self, from: data)
            throw GithubError.basicError(basicError)
        }
    }
}
