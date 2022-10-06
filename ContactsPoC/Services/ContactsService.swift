//
//  ContactsService.swift
//  ContactsPoC
//
//  Created by Justin Davis on 5/10/2022.
//

import Foundation
import Contacts

protocol ContactsService {
    
    func requestAccess(arg1: String, function: @escaping (String) -> Bool) -> Bool
    func createGroupIfNotExists(_ groupName: String) -> Bool
    
}

struct ContactInfo : Identifiable, Hashable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumber: CNPhoneNumber?
    var emailAddress: [CNLabeledValue<NSString>]
}
