import Foundation

// MARK: - LRCLIB API Client

/// Client for the LRCLIB lyrics API
/// API docs: https://lrclib.net/docs
/// - Free, no authentication required
/// - Provides both synced (LRC) and plain-text lyrics
/// - Requires a descriptive User-Agent header
actor LyricsAPI {
    static let shared = LyricsAPI()
    
    private let baseURL = "https://lrclib.net/api"
    private var session: URLSession
    private let userAgent = "Lyrico iOS App/1.0.0 (https://github.com/GitGud031005/lyrics-widget-app)"
    
    private init(timeoutInterval: TimeInterval = 8.0) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.httpAdditionalHeaders = ["User-Agent": userAgent]
        self.session = URLSession(configuration: config)
    }
    
    /// Reconfigures the API client's request timeout interval
    func configure(timeoutInterval: TimeInterval) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.httpAdditionalHeaders = ["User-Agent": userAgent]
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Search
    
    /// Search for tracks matching a query string
    /// Endpoint: GET /api/search?q={query}
    /// Returns: Array of matching tracks with lyrics
    func search(query: String) async throws -> [LRCSearchResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = components.url else {
            throw LyricsAPIError.invalidURL
        }
        
        let (data, response) = try await performRequest(to: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LyricsAPIError.requestFailed(statusCode: 0)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LyricsAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([LRCSearchResult].self, from: data)
        } catch {
            throw LyricsAPIError.decodingFailed
        }
    }
    
    // MARK: - Get by ID
    
    /// Fetch a specific track's lyrics by LRCLIB ID
    /// Endpoint: GET /api/get/{id}
    func getTrack(id: Int) async throws -> LRCSearchResult {
        guard let url = URL(string: "\(baseURL)/get/\(id)") else {
            throw LyricsAPIError.invalidURL
        }
        
        let (data, response) = try await performRequest(to: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LyricsAPIError.requestFailed(statusCode: 0)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LyricsAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(LRCSearchResult.self, from: data)
        } catch {
            throw LyricsAPIError.decodingFailed
        }
    }
    
    // MARK: - Get by Metadata
    
    /// Fetch lyrics by exact track metadata
    /// Endpoint: GET /api/get?track_name={}&artist_name={}&album_name={}&duration={}
    func getLyrics(
        trackName: String,
        artistName: String,
        albumName: String? = nil,
        duration: TimeInterval? = nil
    ) async throws -> LRCSearchResult? {
        var components = URLComponents(string: "\(baseURL)/get")!
        var queryItems = [
            URLQueryItem(name: "track_name", value: trackName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]
        if let album = albumName {
            queryItems.append(URLQueryItem(name: "album_name", value: album))
        }
        if let dur = duration {
            queryItems.append(URLQueryItem(name: "duration", value: String(Int(dur))))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw LyricsAPIError.invalidURL
        }
        
        let (data, response) = try await performRequest(to: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LyricsAPIError.requestFailed(statusCode: 0)
        }
        
        // 404 = not found (not an error, just no results)
        if httpResponse.statusCode == 404 { return nil }
        
        guard httpResponse.statusCode == 200 else {
            throw LyricsAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(LRCSearchResult.self, from: data)
        } catch {
            throw LyricsAPIError.decodingFailed
        }
    }
    
    // MARK: - Request Helper
    
    private func performRequest(to url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .timedOut || urlError.code == .networkConnectionLost {
                throw LyricsAPIError.offline
            }
            throw urlError
        }
    }
}

// MARK: - Error Types

enum LyricsAPIError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case offline
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let code):
            return "Request failed (HTTP \(code))"
        case .decodingFailed:
            return "Failed to decode response"
        case .offline:
            return "No internet connection. Please check your network settings."
        }
    }
}
