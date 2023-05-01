//
//  SKServerConnection.swift
//  skncat
//
//  Created by sun on 2023/05/01.
//

import Foundation
import Network

final class SKServerConnection {
    typealias ID = Int

    // MARK: - Properties

    /// counter for all connection IDs
    private static var nextID: ID = .zero

    let connection: NWConnection
    let id: ID
    var callBackStopHandler: ((Error?) -> Void)? = nil

    /// TCP maximum package size
    private let MTU = 1500


    // MARK: - Init(s)

    init(_ connection: NWConnection) {
        self.connection = connection
        id = SKServerConnection.nextID
        SKServerConnection.nextID &+= 1
    }


    // MARK: - Methods

    /// configures stateHandler, prepares to recieve data and starts the connection
    func start() {
        print("Connection \(id) will start")
        configure()
    }

    func sendData(_ data: Data) {
        connection.send(content: data, completion: .contentProcessed({ [weak self, id] error in
            guard let error
            else {
                print("Connection \(id) did send, data: \(data as NSData)" )
                return
            }

            self?.connectionDidFail(error: error)
        }))
    }

    func stop() {
        print("Connection \(id) will stop")
        // TODO: maybe send some kind of error message to client? 
        stop(error: nil)
    }

    private func configure() {
        connection.stateUpdateHandler = stateDidChange(to:)
        configureDataReceiveHandler()
        connection.start(queue: .main)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .ready:
            print("Connection \(id) ready")
        case .failed(let error), .waiting(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    /// resends receive data to the client if possible
    private func configureDataReceiveHandler() {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: MTU
        ) { [weak self, id] data, _, isComplete, error in

            if let data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8)
                print("Connection \(id) did receive, data: \(data as NSData), string: \(message ?? "-")")
                self?.sendData(data)
            }

            if isComplete {
                self?.connectionDidEnd()
            } else if let error {
                self?.connectionDidFail(error: error)
            } else {
                self?.configureDataReceiveHandler()
            }
        }
    }

    private func connectionDidFail(error: Error) {
        print("Connection \(id) did fail, error: \(error)")
        stop(error: error)
    }

    private func connectionDidEnd() {
        print("Connection \(id) did end")
        stop(error: nil)
    }

    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        callBackStopHandler?(error)
        callBackStopHandler = nil
    }
}
