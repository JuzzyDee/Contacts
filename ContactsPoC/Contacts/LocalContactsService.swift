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
    
    private let contactListName: String = "HazChat Favourite Contacts"
   
    @Published private(set) var contactGroup: CNGroup?
    
    init() {
        //Request contact access when app starts to make life easier.
        Task {
            _ = await requestAccess()
        }
    }
    
    func contactInGroup(contact: CNContact) async -> Bool {
        
        var result = [CNContact]()
        
        do {
            if await requestAccessAndCreateGroup() {
                let cnRequest: CNContactFetchRequest = .init(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
                if let groupIdentifier = contactGroup?.identifier {
                    cnRequest.predicate = CNContact.predicateForContactsInGroup(withIdentifier: groupIdentifier)
                    try contactStore.enumerateContacts(with: cnRequest, usingBlock: { (contactInGroup, status) in
                        result.append(contactInGroup)
                    })
                    
                    let resultCount = result.filter {
                        $0.givenName == contact.givenName && $0.familyName == contact.familyName
                    }
                    .count
                    return resultCount != 0
                }
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        //If we made it here we have a group issue, so return false
        return false
    }

    
    func requestAccessAndCreateGroup() async -> Bool {
        if await requestAccess() {
            return createGroupIfNotExists(contactListName)
        }
        return false
    }
    
    func executeSave(_ saveRequest: CNSaveRequest) {
        do{
            try contactStore.execute(saveRequest)
         } catch let error{
             print(error)
         }
    }
    
    func requestAccess() async -> Bool {
        var accessGranted: Bool = false
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            accessGranted = true
        case .denied:
            //TO-DO JD: Try and request again, but return false if denied
            accessGranted = false
        case .notDetermined:
            do {
                accessGranted = try await contactStore.requestAccess(for: .contacts)
            } catch {
                print("Error requesting Contact Access: \(error)")
            }
        default:
            accessGranted = false
        }
        
        return accessGranted
        
    }
    
//    func requestAccess(arg1: String, function: @escaping (String) -> Bool) -> Bool {
//
//        let store = CNContactStore()
//        var createdGroup: Bool = false
//
//        switch CNContactStore.authorizationStatus(for: .contacts) {
//        case .authorized:
//            createdGroup = function(arg1)
//        case .denied:
//            store.requestAccess(for: .contacts) { granted, error in
//                if granted {
//                    createdGroup = function(arg1)
//                }
//            }
//        case .restricted, .notDetermined:
//            store.requestAccess(for: .contacts) { granted, error in
//                if granted {
//                    createdGroup = function(arg1)
//                }
//            }
//        @unknown default:
//            print("error")
//            createdGroup = false
//        }
//
//        return createdGroup
//
//    }
   
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

