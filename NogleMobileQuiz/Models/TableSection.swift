//
//  TableItem.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxDataSources

/// Data structure for table section to host the items
struct TableSection {
    struct Item {
        let name: String
        let segment: Segment
        let price: Double?
    }

    let items: [Item]
}

extension TableSection: SectionModelType {
    init(original: TableSection, items: [Item]) {
        self.items = items
    }
}
