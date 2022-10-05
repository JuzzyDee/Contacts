//
//  ContentView.swift
//  ContactsPoC
//
//  Created by Justin Davis on 29/9/2022.
//

import SwiftUI
import Contacts

struct LandingView: View {
    
    let vm = LandingViewViewModel.init()
    
    @State var contact: [CNContact]?
    @State var showPicker = false
    
    var body: some View {
        ZStack {
            ContactPicker(
                showPicker: $showPicker,
                onSelectContacts: {c in
                    self.contact = c})
            VStack{
                Spacer()
                Button(action: {
                    self.showPicker.toggle()
                }) {
                    Text("Pick a contact")
                }
                Spacer()
                List {
                    ForEach(self.contact ?? [], id: \.self) { c in
                        let contact: CNMutableContact = c.mutableCopy() as! CNMutableContact
                        ContactRow(contact: contact)
                    }
                }
                Spacer()
            }
        }
    }
}

struct ContactRow: View {
    
    var contact: CNMutableContact
    
    var body: some View {
        HStack {
        VStack {
            HStack {
                Text("Name: \(contact.givenName ) \(contact.familyName)")
                Spacer()
            }
            HStack {
                if contact.emailAddresses.count > 0 {
                    Text("Email: \(contact.emailAddresses.first?.value as! String)")
                }
                Spacer()
            }
        }
        .padding()
            VStack {
                Button {
                    // Add to favourites
                    print("Favourite \(contact.givenName)")
                } label: {
                    Text("Favourite")
                        .font(.caption)
                }
            }
        }
    }
}


struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
