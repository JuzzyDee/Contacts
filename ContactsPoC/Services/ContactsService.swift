//
//  ContactsService.swift
//  ContactsPoC
//
//  Created by Justin Davis on 5/10/2022.
//

import Foundation
import Contacts

protocol ContactsService {
    
    func requestAccess()
    func fetchContacts(_ searchTerm: String) -> [ContactInfo]
    func createGroupIfNotExists(_ groupName: String)
    
}

struct ContactInfo : Identifiable, Hashable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumber: CNPhoneNumber?
    var emailAddress: [CNLabeledValue<NSString>]
}
