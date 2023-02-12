//
//  PeripheralListViewModel.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 12.02.23.
//

import Foundation
import Combine
import CombineCoreBluetooth

protocol PeripheralListViewModelProtocol: ObservableObject {
    var discoveredDevices: [PeripheralDiscovery] { get set }
    var presendStateAlert: Bool { get set }
    var stateAlertMessage: String { get set }
    func startScaning()
    func stopScaning()
    func cleanList()
}

final class PeripheralListViewModel: PeripheralListViewModelProtocol {
    private let BLEManager: BluetoothManagerProtocol

    private var cancellable: Set<AnyCancellable>

    @Published var discoveredDevices: [PeripheralDiscovery]
    @Published var presendStateAlert: Bool
    @Published var stateAlertMessage: String

    init(BLEManager: BluetoothManagerProtocol ) {
        self.BLEManager = BLEManager
        self.cancellable = Set<AnyCancellable>()
        self.discoveredDevices = []
        self.presendStateAlert = false
        self.stateAlertMessage = ""

        BLEManager.didDiscoverPeripheral
            .receive(on: RunLoop.main)
            .sink { [weak self] peripheralDiscovery in
                self?.appendNewDevice(peripheralDiscovery)
            }
            .store(in: &cancellable)

        BLEManager.didUpdateState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .poweredOff:
                    self?.stateAlertMessage = "BLEScaner  is asking to turn on Bluetooth."
                    self?.presendStateAlert = true
                case .unauthorized:
                    self?.stateAlertMessage = "Cardio.Dialog is asking for access to Bluetooth"
                    self?.presendStateAlert = true
                default:
                    break
                }
            }
            .store(in: &cancellable)
    }

    public func startScaning() {
        discoveredDevices.removeAll()
        BLEManager.startScaning()
    }

    public func stopScaning() {
        BLEManager.stopScaning()
    }

    public func cleanList() {
        discoveredDevices.removeAll()
    }
}

// MARK: private methods
private extension PeripheralListViewModel {
    private func appendNewDevice(_ device: PeripheralDiscovery) {
        let deviceIds = discoveredDevices.map { $0.peripheral.id }
        if !deviceIds.contains(device.peripheral.id) {
            discoveredDevices.append(device)
        }
    }
}
