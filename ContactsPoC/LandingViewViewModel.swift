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
    var favouriteGroup: CNGroup?
    
    init() {
        
    }
    
    func contactInGroup(contact: CNContact) async -> Bool {
        let returnVal = await contactsService.contactInGroup(contact: contact)
        return returnVal
    }
    
    func createHazChatGroup() async -> Bool {
        if await contactsService.requestAccessAndCreateGroup() {
            favouriteGroup = contactsService.contactGroup
            print("HazChat Group(\(favouriteGroup?.name ?? "")) Set")
            return true
        }
        print("Error Creating Group")
        return false
    }
    
    func addContactToGroup(contact: CNMutableContact) {
        Task {
            if await createHazChatGroup() {
                let saveRequest = CNSaveRequest()
                saveRequest.addMember(contact, to: favouriteGroup!.copy() as! CNGroup)
                contactsService.executeSave(saveRequest)
            }
        }
    }
    
    func removeContactFromGroup(contact: CNMutableContact) {
        Task {
            if await createHazChatGroup() {
                let saveRequest = CNSaveRequest()
                saveRequest.removeMember(contact, from: favouriteGroup!.copy() as! CNGroup)
                contactsService.executeSave(saveRequest)
            }
        }
    }
    
    func fetchContacts() -> [ContactInfo] {
        DispatchQueue.main.async {
            self.contacts = self.contactsService.fetchContacts("")
        }
        return self.contactsService.fetchContacts("")
    }
    
}



