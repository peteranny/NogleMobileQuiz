//
//  ViewModel.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxCocoa
import RxSwift

class ViewModel {
    struct Inputs {
        let selectSegment: Observable<Segment>
        let selectSortingCriteria: Observable<SortingCriteria>
    }

    struct Outputs {
        let segments: Driver<[Segment]>
        let selectedSegment: Driver<Segment>
        let sections: Driver<[TableSection]>
        let sortingCriteria: Driver<SortingCriteria>
        let binding: Disposable
    }

    /// Bind the inputs to the view model
    /// - Parameter inputs: The inputs to the view model
    /// - Returns: The outputs from the view model
    func bind(inputs: Inputs) -> Outputs {
        let segments = Driver.just(Segment.allCases)
        let selectedSegment = selectedSegmentRelay.asDriver().distinctUntilChanged()
        let sections = Driver
            .combineLatest(itemsRelay.asDriver(), selectedSegmentRelay.asDriver(), sortingCriteriaRelay.asDriver())
            .map { items, segment, sortingCriteria in
                let items = items.filter { $0.segment == segment }
                switch sortingCriteria {
                case .nameAscending:
                    return items.sorted(by: { $0.name < $1.name })
                case .nameDescending:
                    return items.sorted(by: { $0.name > $1.name })
                case .priceAscending:
                    return items.sorted(by: { $0.price ?? -1 < $1.price ?? -1 })
                case .priceDescending:
                    return items.sorted(by: { $0.price ?? -1 > $1.price ?? -1 })
                }
            }
            .map { [TableSection(items: $0)] }
        let sortingCriteria = sortingCriteriaRelay.asDriver()

        let bindSelectSegment = inputs.selectSegment.bind(to: selectedSegmentRelay)
        let bindSortingCriteria = inputs.selectSortingCriteria.bind(to: sortingCriteriaRelay)

        return .init(
            segments: segments,
            selectedSegment: selectedSegment,
            sections: sections,
            sortingCriteria: sortingCriteria,
            binding: Disposables.create([bindSelectSegment, bindSortingCriteria])
        )
    }

    init() {
        fetchMarketNames()
        subscribePrices()
    }

    // MARK: - Private

    private func fetchMarketNames() {
        _ = marketService
            .fetchMarketNames()
            .map { $0.map { name, segment in TableSection.Item(name: name, segment: segment, price: nil) } }
            .subscribe(
                with: itemsRelay,
                onSuccess: { relay, items in relay.accept(items) }
            )
    }

    private func subscribePrices() {
        priceService.prices()
            .withLatestFrom(itemsRelay, resultSelector: { ($0, $1) })
            .map { prices, items in
                items.map { TableSection.Item(name: $0.name, segment: $0.segment, price: prices[$0.name]) }
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
    }

    private let marketService = MarketService()
    private let priceService = PriceService()
    private let selectedSegmentRelay = BehaviorRelay<Segment>(value: .spot)
    private let itemsRelay = BehaviorRelay<[TableSection.Item]>(value: [])
    private let sortingCriteriaRelay = BehaviorRelay<SortingCriteria>(value: .nameAscending)
    private let disposeBag = DisposeBag()
}
