//
//  QuoteViewModel.swift
//  CombineDemo
//
//  Created by Pardy Panda Mac Mini on 16/05/23.
//

import Foundation
import Combine

class QuoteViewModel {
    //Enums
    
    //Input is what which is send by the View controller
    enum Input {
        case viewDidAppear
        case refreshButtonDidTap
    }

    //Output is what which is send by the View controller
    enum Output {
        case fetchQuoteDidFail(error: Error)
        case fetchQuoteIsSucceed(quote: Quote)
        case isRefreshButtonEnabled(isBtnEnabled: Bool)
    }

    //Variables
    private let quoteServiceType : QuotesServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellable = Set<AnyCancellable>()
    private let service = QuotesService(apirequest: APIManager(), enviroment: .development)
        
    init(quoteServiceType: QuotesServiceType = QuotesService(apirequest: APIManager(), enviroment: .development)) {
        self.quoteServiceType = quoteServiceType
    }

    func transformData(input : AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        
        input.sink { [weak self] event in
            switch event {
            case .refreshButtonDidTap:
                self?.getRandomQuote()
            case .viewDidAppear :
                self?.getRandomQuote()
            }
        }.store(in: &cancellable)
        
        return output.eraseToAnyPublisher()
    }
    
    
    func getRandomQuote() {
        service.getRandomGeneratedQuote()
            .sink { (completion) in
                switch completion {
                case .failure(let error):
                    print("oops got an error \(error.localizedDescription)")
                case .finished:
                    print("Nothing to do here")
                }
            
            } receiveValue: { quote in
                self.output.send(.fetchQuoteIsSucceed(quote: quote))
                print("New Quote :- \(quote.content ?? "")")
            }.store(in: &cancellable)
    }
    
    func getQuotesByLimit(){
        service.getQuotesByLimit()
            .sink { (completion) in
                switch completion {
                case .failure(let error):
                    self.output.send(.fetchQuoteDidFail(error: error))
                case .finished:
                    print("Completed")
                }
            } receiveValue: { quotes in
                print("All Quotes By Limit :\(quotes)")
            }.store(in: &cancellable)

    }
    
    func getAllQuotes(){
        service.getAllQuotes()
            .sink { (completion) in
                switch completion {
                case .failure(let error) :
                    print("Error Occured :\(error)")
                case .finished :
                    print("Completed")
                }
                
            } receiveValue: { response in
                print("All Quotes :\(response)")
            }.store(in: &cancellable)
    }
}
