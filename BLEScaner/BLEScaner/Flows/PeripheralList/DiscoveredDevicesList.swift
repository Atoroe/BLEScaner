//
//  DiscoveredDevicesList.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 12.02.23.
//

import SwiftUI
import CombineCoreBluetooth

struct DiscoveredDevicesList: View {
    let devices: [PeripheralDiscovery]

    var body: some View {
        List {
            ForEach(0..<(devices.count), id: \.self) { index in
                let device = devices[index]
                NavigationLink(destination: DeviceDetailsView(viewModel: DeviceDetailsViewModel(BLEManager: BluetoothManager.shared, device: device.peripheral))) {
                    VStack {
                        HStack {
                            Text("\(device.peripheral.name ?? "")")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        HStack {
                            Text("\(device.peripheral.id.uuidString)")
                            Spacer()
                        }
                    }
                    .frame(height: 100)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct List_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveredDevicesList(devices: [])
    }
}
