//
//  APICaller.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 04.10.2023.
//
import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let apiKey = "xxx" // Replace with your actual API key
        static let baseURL = "https://newsapi.org/v2"
    }
    
    private init() {}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/top-headlines?country=US&apiKey=\(Constants.apiKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

