//
//  NetworkManager.swift
//  JustPick
//
//  Created by Julian on 12/8/24.
//

import Foundation

// MARK: Structs
struct TMDBMovieResponse: Codable {
    var results: [Movie]
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    
    var fullPosterPath: URL? {
        URL(string: APIConfig.imageBaseURL + posterPath)
    }
}

enum TMDBError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError
    case serverError(Int)    // Includes the HTTP status code
    case unknown(Error)      // Wraps any other unexpected errors
}

// MARK: API Config
enum APIConfig {
    // Base URL for images
    static let imageBaseURL = "https://image.tmdb.org/t/p/original"
    
    // Get API key from config file
    static let apiKey: String = {
        guard let key = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String else {
            fatalError("Could not find TMDB_API_KEY in info.plist. ")
        }
        return key
    }()
    
    // Get the access token from config file
    static let accessToken: String = {
        guard let token = Bundle.main.infoDictionary?["TMDB_API_READ_ACCESS_TOKEN"] as? String else {
            fatalError("Could not find TMDB_API_READ_ACCESS_TOKEN in info.plist.")
        }
        return token
    }()
}

@Observable class NetworkManager {

    var movies: [Movie] = []
    
    init() {
        Task {
            await loadMovies() // updates self.movies array
        }
    }
    
//    func testAPIConfig() {
//        print("Testing API Configuration...")
//        print("API Key: \(String(APIConfig.apiKey.prefix(5)))...")
//        print("Access Token exists: \(APIConfig.accessToken.isEmpty ? "No" : "Yes")")
//        
//        Task {
//            do {
//                let url = URL(string: "https://api.themoviedb.org/3/authentication")!
//                var request = URLRequest(url: url)
//                request.httpMethod = "GET"
//                request.timeoutInterval = 10
//                request.allHTTPHeaderFields = [
//                    "accept": "application/json",
//                    "Authorization": "Bearer \(APIConfig.accessToken)"
//                ]
//                
//                let (data, _) = try await URLSession.shared.data(for: request)
//                print(String(decoding: data, as: UTF8.self))
//                
//                
//            } catch {
//                print("API Test Error: \(error.localizedDescription)")
//            }
//        }
//    }
    
    // MARK: Fetch Movies
    func fetchMovies() async throws -> [Movie] {
        // First, set up the URL with query parameters
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
        ]
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(APIConfig.accessToken)"
        ]
        
        let(data, response) = try await URLSession.shared.data(for: request)
        print(String(decoding: data, as: UTF8.self))
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(TMDBMovieResponse.self, from: data)
            return response.results
        } catch {
            throw TMDBError.decodingError
        }
    }
    
    // MARK: Load Movies
    func loadMovies() async {
        do {
            // Fetch new movies from the API
            let fetchedMovies = try await fetchMovies()
            
            // Update our movies array with the new data
            // This will automatically trigger UI updates thanks to @Observable
            self.movies = fetchedMovies
            
        } catch TMDBError.serverError(let statusCode) {
            print("Server returned error code: \(statusCode)")
        } catch TMDBError.decodingError {
            print("Failed to decode the movie data")
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Fetch Movie by ID
    func fetchMovieByID(movieID: Int) async throws -> Movie {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "language", value: "en-US"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(APIConfig.accessToken)"
        ]

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let movie = try decoder.decode(Movie.self, from: data)
            return movie
        } catch {
            print("fetchMovieByID: Decoding error \(error)")
            throw TMDBError.decodingError
        }
        
    }
}
