//
//  KeypadView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import SwiftUI

struct KeypadView: View {

    @Binding var pin: String

    let pinLength: Int
    var onFaceIdTap: (() -> Void)?

    let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 20),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {

            ForEach(1...9, id: \.self) { number in
                KeypadButton(text: "\(number)") {
                    if pin.count < pinLength { pin.append("\(number)") }
                }
            }

            if let onFaceIdTap {
                Button(action: onFaceIdTap) {
                    Image(systemName: "faceid")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                        .frame(width: 75, height: 75)
                }
            } else {
                Spacer()
            }

            KeypadButton(text: "0") {
                if pin.count < pinLength { pin.append("0") }
            }

            Button(action: {
                if !pin.isEmpty { pin.removeLast() }
            }) {
                Image(systemName: "delete.left.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.primary)
                    .frame(width: 75, height: 75)
            }
        }
    }
}
