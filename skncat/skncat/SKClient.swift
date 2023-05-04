//
//  SKClient.swift
//  skncat
//
//  Created by sun on 2023/05/04.
//

import Foundation
import Network

final class SKClient {

    // MARK: - Properties
    private let server: NWEndpoint.Host
    private let port: NWEndpoint.Port
    private let connection: SKClientConnection

    
    // MARK: - Init(s)

    init?(server: String, port: UInt16) {
        guard let port = NWEndpoint.Port(rawValue: port)
        else {
            return nil
        }

        self.server = NWEndpoint.Host(server)
        self.port = port
        connection = SKClientConnection(.init(host: self.server, port: self.port, using: .tcp))
    }


    // MARK: - Methods

    func start() {
        print("Client connecting to server: \(server) via port: \(port)")
        connection.callBackStopHandler = connectionDidStop(error:)
        connection.start()
    }

    func stop() {
        connection.stop()
    }

    func send(data: Data) {
        connection.sendData(data)
    }

    func connectionDidStop(error: Error?) {
        error == nil ? exit(EXIT_SUCCESS) : exit(EXIT_FAILURE)
    }
}
