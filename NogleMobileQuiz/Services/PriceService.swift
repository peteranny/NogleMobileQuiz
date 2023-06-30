//
//  FeedServices.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxSwift

class PriceService {
    /// The stream of maps from market names to their prices.
    /// The prices may change and get emitted.
    func prices() -> Observable<[String: Double]> {
        let url = URL(string: "wss://ws.btse.com/ws/futures")!
        let task = URLSession.shared.webSocketTask(with: url)

        // Helper method to start the connection
        func resume() {
            task.resume()
        }

        // Helper method to send an object to the web socket
        @Sendable func send(_ object: [AnyHashable: Any]) async {
            await withCheckedContinuation { continuation in
                let data = try! JSONSerialization.data(withJSONObject: object)
                let json = String(data: data, encoding: .utf8)!

                task.send(.string(json)) { error in
                    guard error == nil else { return }
                    continuation.resume()
                }
            }
        }

        // Helper method to receive the latest object from the web socket
        @Sendable func receive() async -> Any {
            await withCheckedContinuation { continuation in
                task.receive { result in
                    guard case .success(.string(let json)) = result else { return }
                    let data = json.data(using: .utf8)!
                    let object = try! JSONSerialization.jsonObject(with: data)
                    continuation.resume(returning: object)
                }
            }
        }

        // Helper method to close the connection
        func cancel() {
            task.cancel(with: .goingAway, reason: nil)
        }

        // Create the observable that keeps emitting the prices
        return Observable.create { observer in

            // Start the connection
            resume()

            Task {
                // Subscribe the topic
                await send(["op": "subscribe", "args": ["coinIndex"]])

                // Make sure the subscription is successful
                _ = await receive()

                // Keeps receiving the following prices from the topic
                while true {
                    let object = await receive()
                    let values = ((object as! [String: Any])["data"] as! [String: [String: Any]]).values
                    let pairs: [(String, Double)] = values.map { ($0["name"]! as! String, $0["price"] as! Double) }
                    let map = Dictionary(pairs) { $1 }

                    // Emit the prices
                    observer.onNext(map)
                }
            }

            return Disposables.create {
                // Close the connection on dispose
                cancel()
            }
        }
    }
}
