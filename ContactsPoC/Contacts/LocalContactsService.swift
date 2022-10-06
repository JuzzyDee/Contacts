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
    
    private let contactStore: CNContactStore = CNContactStore()
   
    @Published private(set) var contactGroup: CNGroup?

    
    func requestAccessAndCreateGroup() -> Bool {
        return requestAccess(arg1: "HazChat Favourite Contacts", function: createGroupIfNotExists)
    }
    
    func executeSave(_ saveRequest: CNSaveRequest) {
        do{
            try contactStore.execute(saveRequest)
         } catch let error{
             print(error)
         }
    }
    
    func requestAccess(arg1: String, function: @escaping (String) -> Bool) -> Bool {
            
        let store = CNContactStore()
        var createdGroup: Bool = false
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            createdGroup = function(arg1)
        case .denied:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    createdGroup = function(arg1)
                }
            }
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    createdGroup = function(arg1)
                }
            }
        @unknown default:
            print("error")
            createdGroup = false
        }
        
        return createdGroup
            
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
    
    internal func createGroupIfNotExists(_ groupName: String) -> Bool {
        
        //Check if the group exists
        if checkAndSetGroup(groupName) {
            print("Using existing Group")
            return true
        }
        
        let saveRequest = CNSaveRequest()

        let group = CNMutableGroup()
        group.name = groupName
        
        saveRequest.add(group, toContainerWithIdentifier: nil)

        do {
            try contactStore.execute(saveRequest)
            if checkAndSetGroup(groupName) {
                print("No Group Exists, Group Created")
                return true
            } else {
                print("Error: Failed to set Favourites group")
                return false
            }
        }
        catch {
            let err = error as! CNError
            print("Error saving group:\n\(err)")
        }
        return false
    }
    
    internal func checkAndSetGroup(_ groupName: String) -> Bool {
        do {
            let groups: [CNGroup] = try contactStore.groups(matching: nil)
                .filter { $0.name == groupName }
            print("Number of groups with same name \(groups.count)")
            if !groups.isEmpty {
                print("Group already exists, no need to create")
                contactGroup = groups.first
                return true
            }
        } catch {
            print("Error fetching Groups from Store")
        }
        return false
    }
}

