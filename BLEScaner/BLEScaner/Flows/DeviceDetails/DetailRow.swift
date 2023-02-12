//
//  DetailRow.swift
//  BLEScaner
//
//  Created by Artem Poluyanovich on 12.02.23.
//

import SwiftUI

struct DetailRow: View {
    let title: String
    let info: String

    var body: some View {
        HStack {
            Text("\(title): ")
                .fontWeight(.bold)
            Text(info)
            Spacer()
        }
    }
}

struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(title: "Title", info: "Info")
    }
}
