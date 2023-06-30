//
//  SegmentedControl.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/7/1.
//

import RxCocoa
import RxSwift
import UIKit

class SegmentedControl: UISegmentedControl {
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    fileprivate var segments: [String] = [] {
        didSet {
            for (index, segment) in segments.enumerated() {
                insertSegment(withTitle: segment, at: index, animated: false)
            }
        }
    }
}

extension Reactive where Base: SegmentedControl {
    var segments: Binder<[String]> {
        Binder(base) { base, segments in
            base.segments = segments
        }
    }

    var selectedSegment: ControlProperty<String> {
        let values = controlEvent(.valueChanged)
            .compactMap { [weak base] in base?.selectedSegmentIndex }
            .compactMap { [weak base] in base?.segments[$0] }

        let valueSink = Binder<String>(base) { base, segment in
            base.selectedSegmentIndex = base.segments.firstIndex(of: segment) ?? 0
        }

        return ControlProperty(values: values, valueSink: valueSink)
    }
}
