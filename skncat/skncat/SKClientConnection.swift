//
//  SKClientConnection.swift
//  skncat
//
//  Created by sun on 2023/05/04.
//

import Foundation
import Network

// TODO: make protocol?
final class SKClientConnection {

    // MARK: - Properties

    let connection: NWConnection
    let queue = DispatchQueue(label: "Client")
    var callBackStopHandler: ((Error?) -> Void)? = nil

    /// TCP maximum package size
    private let MTU = 1500


    // MARK: - Init(s)

    init(_ connection: NWConnection) {
        self.connection = connection
    }


    // MARK: - Methods

    /// configures stateHandler, prepares to recieve data and starts the connection
    func start() {
        print("Connection will start")
        configure()
        connection.start(queue: queue)
    }

    func sendData(_ data: Data) {
        connection.send(content: data, completion: .contentProcessed({ [weak self] error in
            guard let error
            else {
                print("Connection did send, data: \(data as NSData)" )
                return
            }

            self?.connectionDidFail(error: error)
        }))
    }

    func stop() {
        print("Connection will stop")
        // TODO: maybe send some kind of error message to server?
        stop(error: nil)
    }

    private func configure() {
        connection.stateUpdateHandler = stateDidChange(to:)
        scheduleOneTimeReceiveHandler()
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .ready:
            print("Connection ready")
        case .failed(let error), .waiting(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    /// resends receive data to the client if possible
    private func scheduleOneTimeReceiveHandler() {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: MTU
        ) { [weak self] data, _, isComplete, error in

            if let data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8)
                print("Connection did receive, data: \(data as NSData), string: \(message ?? "-")")
            }

            if isComplete {
                self?.connectionDidEnd()
            } else if let error {
                self?.connectionDidFail(error: error)
            } else {
                self?.scheduleOneTimeReceiveHandler()
            }
        }
    }

    private func connectionDidFail(error: Error) {
        print("Connection did fail, error: \(error)")
        stop(error: error)
    }

    private func connectionDidEnd() {
        print("Connection did end")
        stop(error: nil)
    }

    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        callBackStopHandler?(error)
        callBackStopHandler = nil
    }
}
