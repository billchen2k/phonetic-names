//
//  ContactPhoneticNames.swift
//  PhoneticNames
//
//  Created by Bill Chen on 2023/1/21.
//

import Foundation
import Contacts

struct ContactPhoneticNames {
    var store: CNContactStore
    var contacts: [CNContact]
    var dryRun: Bool
    var force: Bool

    let nameMap: [String: String] = [
        "曾": "zēng",
        "单": "shàn",
        "朴": "piáo",
        "区": "ōu",
    ]

    init(dryRun: Bool = false, force: Bool = false) {
        self.store = CNContactStore()
        self.contacts = []
        self.dryRun = dryRun
        self.force = force
        if dryRun {
            print("Will perform dry run, your contacts will not be modified.")
        }
        if force {
            print("Will force update all phonetic names, even if the phonetic names already exist.")
        }
        if !initPermission() {
            print("cannot get contact permission.")
            return
        }
    }

    private func initPermission() -> Bool {
        let auth = CNContactStore.authorizationStatus(for: .contacts)
        var authed = false
        switch auth {
        case .authorized:
            print("Contact permission already authorized.")
            authed = true
        case .denied, .notDetermined:
            print("Contact permission is not determined. Asking for contact permission...")
            store.requestAccess(for: .contacts) { (access, error) in
                if access {
                    print("Permission granted.")
                    authed = true
                } else {
                    print("Permission denied.")
                }
                if let safeError = error {
                    print("\(safeError.localizedDescription)")
                }
            }
        default:
            break
        }
        return authed
    }

    private func mandarinToLatin(_ src: String) -> String {
        var phonetic = src
        for key in nameMap.keys {
            if src.contains(key) {
                if #available(macOS 13.0, *) {
                    phonetic.replace(key, with: nameMap[key] ?? key)
                } else {
                    phonetic = phonetic.replacingOccurrences(of: key, with: nameMap[key] ?? key)
                }
            }
        }
        return phonetic.applyingTransform(.mandarinToLatin, reverse: false) ?? src
    }

    private mutating func listContacts() {
        contacts.removeAll()
        let keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                       CNContactFormatter.descriptorForRequiredKeys(for: .phoneticFullName)]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        do {
            try store.enumerateContacts(with: fetchRequest) { (contact, stop) in
                contacts.append(contact)
            }
        } catch {
            print("unable to list contacts. \(error)")
        }
    }

    public mutating func runFill() {
        listContacts()
        for c in contacts {
            if c.phoneticGivenName.count > 0 || c.phoneticFamilyName.count > 0 || c.phoneticMiddleName.count > 0 {
                if !force {
                    print("Phonetic name already exists: \(c.familyName)\(c.givenName) ( \(c.phoneticFamilyName) \(c.phoneticGivenName) ), skipped.")
                    continue
                }
            }
            let phoneticFamilyName = mandarinToLatin(c.familyName)
            let phoneticMiddleName = mandarinToLatin(c.middleName)
            let phoneticGivenName = mandarinToLatin(c.givenName)
            if phoneticGivenName == c.givenName && phoneticMiddleName == c.middleName && phoneticFamilyName == c.familyName {
                print("Non-Chinese contact name: \(c.familyName)\(c.middleName)\(c.givenName), skipped.")
                continue
            }
            update(for: c.mutableCopy() as! CNMutableContact,
                    withFamilyName: phoneticFamilyName,
                    withMiddleName: phoneticMiddleName,
                    withGivenName: phoneticGivenName)
        }
        if dryRun {
            print("Dry run mode. Your contacts were not modified.")
        } else {
            print("Phonetic names updated.")
        }
    }


    public mutating func runClean() {
        listContacts()
        for c in contacts {
            update(for: c.mutableCopy() as! CNMutableContact, withFamilyName: "", withMiddleName: "", withGivenName: "")
        }
        if dryRun {
            print("Dry run mode. Your contacts were not modified.")
        } else {
            print("Phonetic names cleaned.")
        }
    }

    private func update(for contact: CNMutableContact,
                        withFamilyName familyName: String,
                        withMiddleName middleName: String,
                        withGivenName givenName: String) {
        let readablePhonetic = (familyName.count + middleName.count + givenName.count) == 0 ?
                "[empty]" : "\(familyName)\(middleName) \(givenName)"
        print("Setting phonetic names for \(contact.familyName)\(contact.middleName)\(contact.givenName): \(readablePhonetic).")
        let saveRequest = CNSaveRequest()
        contact.phoneticFamilyName = familyName
        contact.phoneticMiddleName = middleName
        contact.phoneticGivenName = givenName
        if dryRun {
            return
        }
        saveRequest.update(contact)
        do {
            try store.execute(saveRequest)
            Thread.sleep(forTimeInterval: 0.05)
        } catch {
            print("Fail to execute store request: \(error)")
        }
    }
}
