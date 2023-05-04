//
//  SKServer.swift
//  skncat
//
//  Created by sun on 2023/05/01.
//

import Foundation
import Network

final class SKServer {
    typealias ConnectionID = Int


    // MARK: - Properties

    private let port: NWEndpoint.Port

    /// notified when a new connection for the assigned port is created and calls newConnectionHandler as a response
    /// (i.e. abstracted socket)
    private let listener: NWListener

    /// dictionary of all active connections
    private var connections = [ConnectionID: SKServerConnection]()


    // MARK: - Init(s)

    init?(port: UInt16) {
        guard let port = NWEndpoint.Port(rawValue: port),
              let listener = try? NWListener(using: .tcp, on: port)
        else {
            return nil
        }

        self.port = port
        self.listener = listener
    }


    // MARK: - Methods

    func start() throws {
        print("Server starting...")
        configureListener()
        // TODO: why main..?
        listener.start(queue: .main)
    }

    private func configureListener() {
        listener.newConnectionHandler = configureConnection(_:)
        listener.stateUpdateHandler = stateDidChange(to:)
    }

    /// adds, configures, and starts a new (given) connection
    private func configureConnection(_ connection: NWConnection) {
        let connection = SKServerConnection(connection)
        connections[connection.id] = connection
        connection.callBackStopHandler = { [weak self] _ in self?.connectionDidStop(connection) }
        connection.start()
        // TODO: remove force unwrapping
        connection.sendData("Welcome you are connection: \(connection.id)".data(using: .utf8)!)
        print("Server did open connection \(connection.id)")
    }

    private func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .ready:
            print("Server ready")
        case .failed(let error):
            print("Server failure, error: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        default:
            break
        }
    }

    /// removes the given connection
    private func connectionDidStop(_ connection: SKServerConnection) {
        connections.removeValue(forKey: connection.id)
        print("Server did close connection \(connection.id)")
    }

    /// stops the server cleanly
    private func stop() {
        listener.stateUpdateHandler = nil
        listener.newConnectionHandler = nil
        listener.cancel()
        connections.values.forEach {
            $0.callBackStopHandler = nil
            $0.stop()
        }
        connections.removeAll()
    }
}
