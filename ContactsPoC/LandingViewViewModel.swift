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
    
    func createHazChatGroup() {
        if contactsService.requestAccessAndCreateGroup() {
            favouriteGroup = contactsService.contactGroup
            print("HazChat Group(\(favouriteGroup?.name ?? "")) Set")
        } else {
            print("Error Creating Group")
        }
    }
    
    func addContactToGroup(contact: CNMutableContact) {
        
        createHazChatGroup()
        
        let saveRequest = CNSaveRequest()
        saveRequest.addMember(contact, to: favouriteGroup!.copy() as! CNGroup)
        
        contactsService.executeSave(saveRequest)
        
    }
    
    func fetchContacts() -> [ContactInfo] {
        DispatchQueue.main.async {
            self.contacts = self.contactsService.fetchContacts("")
        }
        return self.contactsService.fetchContacts("")
    }
    
}



