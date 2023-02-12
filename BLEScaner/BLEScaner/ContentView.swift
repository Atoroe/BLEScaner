//
//  ContentView.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 11.02.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PeripheralListView(viewModel: PeripheralListViewModel(BLEManager: BluetoothManager.shared))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
