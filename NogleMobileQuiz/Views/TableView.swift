//
//  TableView.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class TableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)

        backgroundColor = .clear
        register(TableViewCell.self, forCellReuseIdentifier: "cell")

        rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let dataSources = RxTableViewSectionedAnimatedDataSource<TableSection> { _, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.configure(item.name, price: item.price)
        return cell
    }

    fileprivate let headerView = TableHeaderView()
    private let disposeBag = DisposeBag()
}

extension TableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView
    }
}

extension Reactive where Base: TableView {
    var sections: (Observable<[TableSection]>) -> Disposable {
        items(dataSource: base.dataSources)
    }

    var sortingCriteria: ControlProperty<SortingCriteria> {
        base.headerView.rx.sortingCriteria
    }
}

// MARK: - TableViewCell

private class TableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white.withAlphaComponent(0.8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ name: String, price: Double?) {
        textLabel?.text = name
        detailTextLabel?.text = price.map { NSNumber(value: $0) }.map { formatter.string(from: $0)! }
    }

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
}

private class TableHeaderView: UIView {
    init() {
        super.init(frame: .zero)

        let stackView = UIStackView(arrangedSubviews: [sortByNameButton, UIView(), sortByPriceButton])
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])

        stackView.axis = .horizontal
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let sortByNameButton = TableViewHeaderButton("Name", ascending: "Name ▲", descending: "Name ▼")
    fileprivate let sortByPriceButton = TableViewHeaderButton("Price", ascending: "▲ Price", descending: "▼ Price")
}

extension Reactive where Base: TableHeaderView {
    var sortingCriteria: ControlProperty<SortingCriteria> {
        let values = Observable<SortingCriteria>.merge(
            base.sortByNameButton.rx.buttonState.compactMap { $0.unlessNormal }.map { $0 == .ascending ? .nameAscending : .nameDescending },
            base.sortByPriceButton.rx.buttonState.compactMap { $0.unlessNormal }.map { $0 == .ascending ? .priceAscending : .priceDescending }
        )

        let valueSink = Binder<SortingCriteria>(base) { base, criteria in
            switch criteria {
            case .nameAscending:
                base.sortByNameButton.buttonState = .ascending
                base.sortByPriceButton.buttonState = .normal
            case .nameDescending:
                base.sortByNameButton.buttonState = .descending
                base.sortByPriceButton.buttonState = .normal
            case .priceAscending:
                base.sortByNameButton.buttonState = .normal
                base.sortByPriceButton.buttonState = .ascending
            case .priceDescending:
                base.sortByNameButton.buttonState = .normal
                base.sortByPriceButton.buttonState = .descending
            }
        }

        return ControlProperty(values: values, valueSink: valueSink)
    }
}

private class TableViewHeaderButton: UIButton {
    enum ButtonState {
        case normal
        case ascending
        case descending

        var unlessNormal: ButtonState? {
            if case .normal = self {
                return nil
            }
            return self
        }
    }

    init(_ normal: String, ascending: String, descending: String) {
        self.normal = normal
        self.ascending = ascending
        self.descending = descending
        super.init(frame: .zero)

        setTitle(normal, for: .normal)
        setTitleColor(.black, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let normal: String
    let ascending: String
    let descending: String

    var buttonState: ButtonState = .normal {
        didSet {
            switch buttonState {
            case .normal:
                setTitle(normal, for: .normal)
            case .ascending:
                setTitle(ascending, for: .normal)
            case .descending:
                setTitle(descending, for: .normal)
            }
        }
    }
}

extension Reactive where Base: TableViewHeaderButton {
    var buttonState: Observable<TableViewHeaderButton.ButtonState> {
        tap.compactMap { [weak base] in base?.buttonState }
            .map { state -> TableViewHeaderButton.ButtonState in
                switch state {
                case .normal, .descending:
                    return .ascending
                case .ascending:
                    return .descending
                }
            }
    }
}
