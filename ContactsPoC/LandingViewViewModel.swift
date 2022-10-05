//
//  LandingViewViewModel.swift
//  ContactsPoC
//
//  Created by Justin Davis on 29/9/2022.
//

import Foundation
import Contacts
import SwiftUI

class LandingViewViewModel : ObservableObject {
    
    
    private var contactsService: LocalContactsService = .init()
    
    var contacts = [ContactInfo.init(firstName: "", lastName: "", emailAddress: [])]
    
    init() {
        contactsService.requestAccess()
        self.contacts = fetchContacts()
        print(self.contacts)
    }
    
    func fetchContacts() -> [ContactInfo] {
        DispatchQueue.main.async {
            self.contacts = self.contactsService.fetchContacts("")
        }
        return self.contactsService.fetchContacts("")
    }
    
}



