//
//  ContentView.swift
//  ContactsPoC
//
//  Created by Justin Davis on 29/9/2022.
//

import SwiftUI
import Contacts

@MainActor fileprivate let vm = LandingViewViewModel.init()

struct LandingView: View {
    
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
                    Text("Pick Contacts to Sign In")
                }
                Spacer()
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
    @State var favIcon: String = "heart"
    
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
                    Task {
                        if await vm.contactInGroup(contact: contact) {
                            //TO-DO JD: Remove contact from favourites group
                            favIcon = "heart"
                        } else {
                            vm.addContactToGroup(contact: contact)
                            favIcon = "heart.fill"
                        }
                    }
                } label: {
                    Image(systemName: favIcon)
                        .task {
                            if await vm.contactInGroup(contact: contact) {
                                favIcon = "heart.fill"
                            }
                        }
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
