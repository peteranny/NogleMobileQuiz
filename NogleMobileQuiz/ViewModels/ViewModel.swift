//
//  ViewModel.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxCocoa
import RxSwift

class ViewModel {
    struct Inputs {}

    struct Outputs {
        let sections: Driver<[TableSection]>
    }

    /// Bind the inputs to the view model
    /// - Parameter inputs: The inputs to the view model
    /// - Returns: The outputs from the view model
    func bind(inputs: Inputs) -> Outputs {
        let sections = itemsRelay.asDriver().map { [TableSection(items: $0)] }

        return .init(sections: sections)
    }

    init() {
        fetchMarketNames()
        subscribePrices()
    }

    // MARK: - Private

    private func fetchMarketNames() {
        _ = marketService
            .fetchMarketNames()
            .map { $0.map { TableSection.Item(name: $0, price: nil) } }
            .subscribe(
                with: itemsRelay,
                onSuccess: { relay, items in relay.accept(items) }
            )
    }

    private func subscribePrices() {
        priceService.prices()
            .withLatestFrom(itemsRelay, resultSelector: { ($0, $1) })
            .map { prices, items in
                items.map { TableSection.Item(name: $0.name, price: prices[$0.name]) }
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
    }

    private let marketService = MarketService()
    private let priceService = PriceService()
    private let itemsRelay = BehaviorRelay<[TableSection.Item]>(value: [])
    private let disposeBag = DisposeBag()
}
