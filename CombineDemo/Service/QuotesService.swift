//
//  QuotesServiceType.swift
//  CombineDemo
//
//  Created by Pardy Panda Mac Mini on 16/05/23.
//

import Foundation
import Combine

public typealias Headers = [String:String]

enum QuoteServiceEndpoints {
    // organise all the end points here for clarity
    
    // For Single Random Quote
    case getRandomQuote
    
    // Get Limited Random Quote by Limit
    case getLimitedQuotes(limit : Int)
    
    case getAllQuotes
    
    //specify the type of HTTP request
    var httpMethod : HTTPMethod {
        switch self {
        case .getRandomQuote:
            return .GET
            
        case .getLimitedQuotes:
            return .GET
            
        case .getAllQuotes:
            return .GET
        }
    }
    
    //Compose the APIRequest
    func createRequest(token: String , environment : Environment) -> APIRequest {
        var headers : Headers = [:]
        headers["Content-Type"] = "application/json"
        headers["Authorization"] = "Bearer \(token)"
        return APIRequest(url: getURL(environment: environment), headers: headers , reqBody: requestBody , httpMethod: httpMethod)
    }
    
    //Encodable Body for Post
    var requestBody : Encodable? {
        switch self {
        default:
            return nil
        }
    }
    
    //QueryParams URL components
    func createRandomQuotesURL(limit: Int , baseURL : String) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.quotable.io"
        urlComponents.path = "/quotes/random"
        urlComponents.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        return urlComponents.url!
    }
    
    //Compose URL for every endpoints
    func getURL(environment: Environment) -> String{
        let baseURL = environment.BaseURL
        switch self {
        case .getRandomQuote:
            return "\(baseURL)random"
            
        case .getLimitedQuotes(let limit):
            return "\(createRandomQuotesURL(limit: limit, baseURL: "\(baseURL)quotes/random"))"
            
        case .getAllQuotes:
            return "\(baseURL)quotes"
        }
    }
}

protocol QuotesServiceType {
//    func getRandomQuotes() -> AnyPublisher<Quote, Error>
    //Reusable Generic API call
    func getRandomGeneratedQuote() -> AnyPublisher<Quote, NetworkError>
    func getQuotesByLimit() -> AnyPublisher<[Quote], NetworkError>
    func getAllQuotes() -> AnyPublisher<QuotesModel, NetworkError>
}

class QuotesService : QuotesServiceType {

    private var apirequest : APIManager
    private var enviroment : Environment = .development
    
    //Inject testablity
    init(apirequest: APIManager, enviroment: Environment) {
        self.apirequest = apirequest
        self.enviroment = enviroment
    }
    
    
    // Get Random Quotes
    func getRandomGeneratedQuote() -> AnyPublisher<Quote, NetworkError> {
        let endPoint = QuoteServiceEndpoints.getRandomQuote
        let request = endPoint.createRequest(token: "", environment: enviroment)
        return self.apirequest.apiCall(request: request)
    }
    
    // Get Random Quotes by Limit
    func getQuotesByLimit() -> AnyPublisher<[Quote], NetworkError> {
        let endPoint = QuoteServiceEndpoints.getLimitedQuotes(limit: 5)
        let request = endPoint.createRequest(token: "", environment: enviroment)
        return self.apirequest.apiCall(request: request)
    }
    
    // Get All Quotes
    func getAllQuotes() -> AnyPublisher<QuotesModel, NetworkError> {
        let endPoint = QuoteServiceEndpoints.getAllQuotes
        let req = endPoint.createRequest(token: "", environment: enviroment)
        return self.apirequest.apiCall(request: req)
    }
    
    // Note :- This is Without the Generic Reusable Network call
    /*    func getRandomQuotes() -> AnyPublisher<Quote, Error> {
     let url = URL(string: "https://api.quotable.io/random")!
     
     return URLSession.shared.dataTaskPublisher(for: url)
     .catch { error in
     return Fail(error: error)
     .eraseToAnyPublisher()
     }.map({ $0.data })
     .decode(type: Quote.self, decoder: JSONDecoder())
     .eraseToAnyPublisher()
     }*/
}



