//
//  main.swift
//  skncat
//
//  Created by sun on 2023/05/01.
//

import Foundation

// server: $ skncat -l <PORT>
// client: $ skncat <SERVER> <PORT>

struct Console {

    // MARK: - Enums

    private enum Host {
        case server(port: UInt16)
        case client(server: (port: UInt16, name: String))
    }


    // MARK: - Functions

    func run() {
        guard let host = parseArguments()
        else {
            print("Error: invalid input")
            return
        }

        switch host {
        case .server(let port):
            print("Starting as server on port: \(port)")
        case .client(let server):
            print("Starting as client, connecting to server \(server.name) port: \(server.port)")
        }

        RunLoop.current.run()
    }

    private func parseArguments() -> Host? {
        let arguments = CommandLine.arguments
        guard arguments.count == 3,
              let port = UInt16(arguments[Metric.port])
        else {
            return nil
        }

        let isServer = arguments[Metric.server] == StringLiteral.serverFlag
        return isServer ? Host.server(port: port) : Host.client(server: (port, arguments[Metric.server]))
    }
}


// MARK: - Constants
fileprivate extension Console {

    enum Metric {
        static let server = 1
        static let port = 2
    }

    enum StringLiteral {
        static let serverFlag = "-l"
        static let localhost = "localhost"
    }
}

Console().run()
