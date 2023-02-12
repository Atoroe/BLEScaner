//
//  DeviceList.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 11.02.23.
//

import SwiftUI
import CombineCoreBluetooth

struct DeviceList: View {
    let devices: [PeripheralDiscovery]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(0..<(devices.count), id: \.self) { index in
                    let device = devices[index]
                    Text("\(device.peripheral.name ?? device.peripheral.id.uuidString)")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct List_Previews: PreviewProvider {
    static var previews: some View {
        DeviceList(devices: [])
    }
}
