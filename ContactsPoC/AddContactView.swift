//
//  ContactView.swift
//  ContactsPoC
//
//  Created by Justin Davis on 5/10/2022.
//

import Foundation
import SwiftUI

struct AddContactView: View {

    @State var name: String = ""

    var body: some View {

        VStack (spacing: 20) {
        
            Text("Add a New Contact:")
                .font(.headline)
            TextField("Enter Name", text: $name)
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        
        }
        .padding()
    
    }
}
