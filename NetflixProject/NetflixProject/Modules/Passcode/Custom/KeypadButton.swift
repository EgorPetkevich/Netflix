//
//  KeypadButton.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import SwiftUI

struct KeypadButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title)
                .frame(width: 75, height: 75)
                .background(Color.secondary.opacity(0.15))
                .clipShape(Circle())
                .foregroundColor(.primary)
        }
    }
}
