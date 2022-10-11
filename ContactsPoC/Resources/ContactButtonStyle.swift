//
//  ButtonStyles.swift
//  ContactsPoC
//
//  Created by Justin Davis on 11/10/2022.
//

import Foundation
import SwiftUI

struct ContactButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.green : Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
