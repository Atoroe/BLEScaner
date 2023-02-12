//
//  DeviceDetailsViewModel.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 12.02.23.
//

import Foundation
import CombineCoreBluetooth

protocol DeviceDetailsViewModelProtocol: ObservableObject {
    var deviceName: String { get set }
    var identifire: String { get set }
    var connectionState: String { get set }
    var isLoading: Bool { get set }
    var isDeviceDesconnected: Bool { get set }
    func connectDevice()
    func disconnect()
}

final class DeviceDetailsViewModel: DeviceDetailsViewModelProtocol {
    private let BLEManager: BluetoothManagerProtocol

    private var device: Peripheral?
    private var cancellable: Set<AnyCancellable>

    @Published public var deviceName: String
    @Published public var identifire: String
    @Published public var connectionState: String
    @Published public var isLoading: Bool
    @Published public var isDeviceDesconnected: Bool

    init(BLEManager: BluetoothManagerProtocol, device: Peripheral?) {
        self.BLEManager = BLEManager
        self.device = device
        self.cancellable = Set<AnyCancellable>()
        self.deviceName = ""
        self.identifire = ""
        self.connectionState = ""
        self.isLoading = true
        self.isDeviceDesconnected = false

        BLEManager.didConnectPeripheral
            .receive(on: RunLoop.main)
            .sink { [weak self] peripheral in
                guard let self = self else {
                    return
                }
                self.deviceName = peripheral.name ?? "Unknown"
                self.identifire = peripheral.identifier.uuidString
                self.connectionState = self.getConnectionStateString(peripheral.state)
                switch peripheral.state {
                case .connected:
                    self.isLoading = false
                default:
                    self.isLoading = true
                }
            }
            .store(in: &cancellable)

        BLEManager.didDisconnectPeripheral
            .receive(on: RunLoop.main)
            .sink { [weak self] (peripheral, _) in
                guard let self = self else {
                    return
                }
                self.connectionState = self.getConnectionStateString(peripheral.state)
                switch peripheral.state {
                case .disconnected:
                    self.isDeviceDesconnected = true
                    self.isLoading = false
                default:
                    break
                }
            }
            .store(in: &cancellable)
    }

    public func connectDevice() {
        guard let peripheral = device else {
            return
        }
        BLEManager.connect(peripheral)
        isLoading = true
    }

    public func disconnect() {
        BLEManager.disconnect()
        isLoading = true
    }
}

// MARK: private methods
private extension DeviceDetailsViewModel {
    private func getConnectionStateString(_ state: CBPeripheralState) -> String {
        let state: String = {
            switch state {
            case .disconnected:
                return "disconnected"
            case .connecting:
                return "connecting"
            case .connected:
                return "connected"
            case .disconnecting:
                return "disconnecting"
            @unknown default:
                return "unknown"
            }
        }()
        return state
    }
}
