//
//  APICaller.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 04.10.2023.
//
import Foundation

enum APIError: Error {
    case noData
}

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let apiKey = "e7859973ec084fb789ee0b888890d934" // Replace with your actual API key
        static let baseURL = "https://newsapi.org/v2"
    }
    private init() {}
    
    private func makeRequest<T: Decodable, U: Decodable>(
        url: URL,
        responseType: U.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(responseType, from: data)
                if let articles = (decodedObject as? APIResponse)?.articles as? T {
                    completion(.success(articles))
                } else {
                    throw DecodingError.dataCorrupted(
                        .init(codingPath: [], debugDescription: "Failed to decode articles")
                    )
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeURL(endpoint: String, parameters: [String: String]) -> URL {
        var components = URLComponents(string: Constants.baseURL + endpoint)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        components.queryItems?.append(URLQueryItem(name: "apiKey", value: Constants.apiKey))
        return components.url!
    }
    
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let url = makeURL(endpoint: "/everything", parameters: ["sortedBy": "popularity", "q": query])
        makeRequest(url: url, responseType: APIResponse.self, completion: completion)
    }
    
    public func getTopStories(page: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        let url = makeURL(endpoint: "/top-headlines", parameters: ["country": "US", "page": "\(page)", "sortBy": "publishedAt"])
        makeRequest(url: url, responseType: APIResponse.self, completion: completion)
    }
    
    public func getTopStoriesFilteredByCategory(category: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        let url = makeURL(endpoint: "/top-headlines", parameters: ["country": "US", "category": category])
        makeRequest(url: url, responseType: APIResponse.self, completion: completion)
    }
    
    public func getTopStoriesFilteredByCountry(country: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        let url = makeURL(endpoint: "/top-headlines", parameters: ["country": "\(country)"])
        makeRequest(url: url, responseType: APIResponse.self, completion: completion)
    }
}
