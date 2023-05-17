//
//  ViewController.swift
//  CombineDemo
//
//  Created by Pardy Panda Mac Mini on 16/05/23.
//

import UIKit
import Combine

class ViewController: UIViewController {

    // UIElements
    @IBOutlet weak var lblQuote: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    
    //Variables
    private let vm = QuoteViewModel()
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    @IBAction func btnRefreshClicked(_ sender: Any) {
        input.send(.refreshButtonDidTap)
    }
    
    func setupUI(){
        btnRefresh.layer.cornerRadius = 12
    
    }
}

//Helper Methods
extension ViewController {
   
    func bind(){
        //View Model Splits Out here
        let output = vm.transformData(input: input.eraseToAnyPublisher())
            output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .fetchQuoteDidFail(let error):
                self?.lblQuote.text = error.localizedDescription
            case .fetchQuoteIsSucceed(let quote):
                self?.lblQuote.text = quote.content
            case .isRefreshButtonEnabled(let isBtnEnabled):
                self?.btnRefresh.isEnabled = isBtnEnabled
            }
        }.store(in: &cancellables)
    }
    
}

