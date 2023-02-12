//
//  BluetoothManager.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 11.02.23.
//

import Foundation
import CoreBluetooth
import CombineCoreBluetooth
import Combine

protocol BluetoothManagerProtocol {
    var didDiscoverPeripheral: AnyPublisher<PeripheralDiscovery, Never> { get }
    var didConnectPeripheral: AnyPublisher<Peripheral, Never> { get }
    var didUpdateState: AnyPublisher<CBManagerState, Never> { get }
    var didFailToConnectPeripheral: AnyPublisher<(Peripheral, Error?), Never> { get }
    var didDisconnectPeripheral: AnyPublisher<(Peripheral, Error?), Never> { get }
    func startScaning()
    func stopScaning()
    func connect(_ peripheral: Peripheral)
    func disconnect()
}

final class BluetoothManager: BluetoothManagerProtocol {
    private let centralManager: CentralManager

    private var cancellable: Set<AnyCancellable>
    private var scanPublisher: AnyCancellable?
    private var connectPublisher: AnyCancellable?
    private var discoveredPeripherals: [PeripheralDiscovery]
    private var connectedPeripheral: Peripheral?

    public var didDiscoverPeripheral: AnyPublisher<PeripheralDiscovery, Never> { centralManager.didDiscoverPeripheral }
    public var didConnectPeripheral: AnyPublisher<Peripheral, Never> { centralManager.didConnectPeripheral }
    public var didUpdateState: AnyPublisher<CBManagerState, Never> { centralManager.didUpdateState }
    public var didFailToConnectPeripheral: AnyPublisher<(Peripheral, Error?), Never> { centralManager.didFailToConnectPeripheral }
    public var didDisconnectPeripheral: AnyPublisher<(Peripheral, Error?), Never> { centralManager.didDisconnectPeripheral }

    static let shared = BluetoothManager()

    private init() {
        self.centralManager = .live(CentralManager.CreationOptions(showPowerAlert: true, restoreIdentifierKey: nil))
        self.cancellable = Set<AnyCancellable>()
        self.discoveredPeripherals = []
    }

    public func startScaning() {
        scanPublisher = centralManager.scanForPeripherals(withServices: nil)
            .sink { [weak self] peripheralDiscovery in
                guard let self = self else { return }
                self.discoveredPeripherals.append(peripheralDiscovery)
            }
        scanPublisher?.store(in: &cancellable)
    }

    public func stopScaning() {
        scanPublisher?.cancel()
    }

    public func connect(_ peripheral: Peripheral) {
        connectPublisher = centralManager.connect(
            peripheral,
            options: CentralManager.PeripheralConnectionOptions(
                notifyOnConnection: true,
                notifyOnDisconnection: true,
                notifyOnNotification: true,
                startDelay: nil
            )
        )
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("\nLog: Connect failure: \(error)")
            }
        }, receiveValue: { peripheral in
            print("\nLog: Connected peripheral: \(peripheral.name ?? peripheral.id.uuidString)")
        })

        connectPublisher?.store(in: &cancellable)
        stopScaning()
    }

    public func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectPublisher?.cancel()
        connectedPeripheral = nil
    }
}
