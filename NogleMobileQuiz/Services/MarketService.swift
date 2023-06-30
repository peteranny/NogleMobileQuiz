//
//  MarketService.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxSwift

class MarketService {
    /// Fetch the array of market names and their respective segments
    func fetchMarketNames() -> Single<[(String, Segment)]> {
        struct Response: Decodable {
            struct Item: Decodable {
                let symbol: String
                let future: Bool
            }

            let data: [Item]
        }

        let url = URL(string: "https://api.btse.com/futures/api/inquire/initial/market")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request)
            .compactMap { try? JSONDecoder().decode(Response.self, from: $0) }
            .map { $0.data.map { ($0.symbol, $0.future ? .futures : .spot) } }
            .asSingle()
    }
}
