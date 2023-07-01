//
//  TableItem.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxDataSources

        /// Data structure for table section to host the items
struct TableSection: Equatable, IdentifiableType {
    struct Item: IdentifiableType, Equatable {
        let name: String
        let segment: Segment
        let price: Double?

        var identity: some Hashable {
            name
        }
    }

    let items: [Item]

    let identity: some Hashable = 0
}

extension TableSection: AnimatableSectionModelType {
    init(original: TableSection, items: [Item]) {
        self.items = items
    }
}
