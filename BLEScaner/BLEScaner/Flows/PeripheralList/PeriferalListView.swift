//
//  PeripheralListView.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 12.02.23.
//

import SwiftUI
import Combine
import CombineCoreBluetooth

struct PeripheralListView<T>: View where T: PeripheralListViewModelProtocol{
    @ObservedObject var viewModel: T
    @State private var isScanning = false

    var body: some View {
        NavigationView {
            VStack {
                if isScanning {
                    VStack {
                        Text("scanning...")
                        ProgressView()
                    }
                    .padding()
                }
                DiscoveredDevicesList(devices: viewModel.discoveredDevices)
                    .padding(.bottom)
                scanStopButton
            }
            .padding(.bottom)
            .navigationTitle("Device List:")
            .onDisappear() {
                viewModel.stopScaning()
                isScanning = false
            }
        }
        .alert(isPresented: $viewModel.presendStateAlert) {
            Alert(title: Text(viewModel.stateAlertMessage), primaryButton: .cancel(), secondaryButton: .default(Text("Settings")) {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        }
    }

    var scanStopButton: some View {
        Button(action: {
            isScanning.toggle()
            if isScanning {
                viewModel.startScaning()
            } else {
                viewModel.stopScaning()
            }
        }, label: {
            let text: String = isScanning ? "Stop Scan" : "Scan Peripheral"
            Text("\(text)")
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.blue)
    }
}

struct PeripheralListView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralListView(viewModel: PeripheralListViewModel(BLEManager: BluetoothManager.shared))
    }
}
