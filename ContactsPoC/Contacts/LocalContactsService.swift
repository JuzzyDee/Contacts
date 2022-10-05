//
//  LocalContactsService.swift
//  ContactsPoC
//
//  Created by Justin Davis on 5/10/2022.
//

import Foundation
import Contacts
import SwiftUI

class LocalContactsService : ContactsService {
    
    @Published private(set) var contacts: [ContactInfo] = [ContactInfo.init(firstName: "", lastName: "", emailAddress: [])]
    
    func createGroupIfNotExists(_ groupName: String) {
        print("This needs to be implemented")
    }
    
    func requestAccess() {
            
        let store = CNContactStore()
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                self.contacts = self.fetchContacts("")
            case .denied:
                store.requestAccess(for: .contacts) { granted, error in
                    if granted {
                        self.contacts = self.fetchContacts("")
                    }
                }
            case .restricted, .notDetermined:
                store.requestAccess(for: .contacts) { granted, error in
                    if granted {
                        self.contacts = self.fetchContacts("")
                    }
                }
            @unknown default:
                print("error")
            }
        }
   
    func fetchContacts(_ searchTerm: String) -> [ContactInfo] {
        
        var contacts = [ContactInfo]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try CNContactStore().enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                contacts.append(ContactInfo(firstName: contact.givenName, lastName: contact.familyName, phoneNumber: contact.phoneNumbers.first?.value, emailAddress: contact.emailAddresses))
            })
        } catch let error {
            print("Failed", error)
        }
        contacts = contacts.sorted {
            $0.firstName < $1.firstName
        }
        return contacts
    }
}

