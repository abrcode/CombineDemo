//
//  APIManager.swift
//  CombineDemo
//
//  Created by Pardy Panda Mac Mini on 17/05/23.
//

import Foundation
import Combine



extension Encodable {
    
    func encode() -> Data? {
        do {
           return try JSONEncoder().encode(self)
        } catch {
            return nil
        }
    }
}

public enum Environment: String, CaseIterable {
    case development
    case staging
    case production
}

extension Environment {
    var BaseURL : String {
        switch self {
        case .development :
            return "https://api.quotable.io/"
        case .staging :
            return ""
        case .production :
            return ""
        }
    }
}


public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public enum NetworkError : Error, Equatable {
    
    case badUrl(error: String)
    case apiError(code: Int, error: String)
    case invalidJSON(error: String)
    case unauthorised(code: Int, error: String)
    case badRequest(code:Int, error:String)
    case serverError(code:Int, error:String)
    case noResponse(error: String)
    case unableToParseData(_ error: String)
    case unknown(code: Int, error: String)
 
}

public struct APIRequest {
    
    let url: String
    let headers: [String: String]?
    let body: Data?
    let httpMethod: HTTPMethod
    
    public init( url: String,
                headers: [String : String]? = nil,
                reqBody: Encodable? = nil,
                httpMethod: HTTPMethod) {
        self.url = url
        self.headers = headers
        self.body = reqBody?.encode()
        self.httpMethod = httpMethod
    }

    public init( url: String,
                headers: [String : String]? = nil,
                reqBody: Data? = nil,
                httpMethod: HTTPMethod) {
        self.url = url
        self.headers = headers
        self.body = reqBody
        self.httpMethod = httpMethod
    }

    func buildURLRequest(with url: URL) -> URLRequest {
        var urlRequest = URLRequest(url:url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers ?? [:]
        urlRequest.httpBody = body
        return urlRequest
    }
    
}


public class APIManager {
    
    func apiCall<T>( request : APIRequest) -> AnyPublisher<T, NetworkError> where T: Encodable , T: Decodable {
        
        //Set URL
        guard let url = URL(string: request.url) else { return
            AnyPublisher(
                //Return a fail publisher if the url is invalid
                Fail<T, NetworkError>(error: NetworkError.badUrl(error: "Invalid URL"))
            )
        }
        
        //DataPublisher Task
        return URLSession.shared
            .dataTaskPublisher(for: request.buildURLRequest(with: url))
            .tryMap { output in
                
                //Throw error if get response error
                guard output.response is HTTPURLResponse else {
                    throw NetworkError.serverError(code: 0, error: "Server Error..!")
                }
                
                //Success Data
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.invalidJSON(error: String(describing: error))
            }.eraseToAnyPublisher()

    }    
    
}
