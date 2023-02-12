//
//  DeviceDetailsView.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 12.02.23.
//

import SwiftUI
import CombineCoreBluetooth

struct DeviceDetailsView<T>: View where T: DeviceDetailsViewModelProtocol {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: T

    var body: some View {
        ZStack {
            VStack {
                Form {
                    VStack {
                        DetailRow(title: "Identifier", info: viewModel.identifire)
                            .padding(.bottom)
                        DetailRow(title: "State", info: "\(viewModel.connectionState)")
                    }
                }
                Spacer()
                Button(action: viewModel.disconnect) {
                    Text("Disconnect")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)
                .disabled(viewModel.isLoading)
            }
            if viewModel.isLoading {
                VStack {
                    Text("wait please...")
                    ProgressView()
                }
            }
        }
        .navigationTitle(viewModel.deviceName)
        .alert(isPresented: $viewModel.isDeviceDesconnected) {
            Alert(title: Text("Device disconnected!"), dismissButton: .cancel() {
                dismiss()
            })
        }
        .onAppear() {
            viewModel.connectDevice()
        }
    }
}

struct DeviceDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetailsView(viewModel: DeviceDetailsViewModel(BLEManager: BluetoothManager.shared, device: nil))
    }
}
