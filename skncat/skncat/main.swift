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


    // MARK: - Methods

    func run() {
        guard let host = parseArguments()
        else {
            print("Error: invalid input")
            return
        }

        switch host {
        case .server(let port):
            if (try? SKServer(port: port)?.start()) == nil {
                print("Error: failed to start server")
                return
            }
        case .client(let server):
            guard let client = SKClient(server: server.name, port: server.port)
            else {
                print("Error: failed to start client")
                return
            }

            client.start()
            receiveInput(for: client)
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

    private func receiveInput(for client: SKClient) {
        while true {
            guard var command = readLine(strippingNewline: true)
            else {
                print("Missing client input")
                continue
            }

            switch command {
            case "CRLF":
                command = "\r\n"
            case "RETURN":
                command = "\n"
            case "exit":
                client.stop()
            default:
                break
            }

            client.send(data: command.data(using: .utf8)!)
        }
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
