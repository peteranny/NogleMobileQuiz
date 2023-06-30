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

    func bind(inputs: Inputs) -> Outputs {
        let sections = itemsRelay.asDriver().map { [TableSection(items: $0)] }

        return .init(sections: sections)
    }

    init() {
        fetchMarketNames()
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

    private let marketService = MarketService()
    private let itemsRelay = BehaviorRelay<[TableSection.Item]>(value: [])
}
