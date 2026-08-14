//
//  AdminProfileViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 14/08/26.
//

import SwiftUI
import CoreData
import Combine

class AdminProfileViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var email = ""
    @Published var contact = ""
    @Published var password = ""
    @Published var imageData: Data?
    
    @Published var showSuccessAlert = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    init() {
        populateFields()
    }
    
    var memberSince: String {
        guard let date = SessionManager.shared.currentAdmin?.timestamp else { return "" }
        return "Member since \(date.formatted(date: .abbreviated, time: .omitted))"
    }
    
    func populateFields() {
        let admin = SessionManager.shared.currentAdmin
        name = admin?.name ?? ""
        email = admin?.email ?? ""
        contact = admin?.contact ?? ""
        password = admin?.password ?? ""
        imageData = admin?.imageData
    }
    
    func saveProfileImage(_ data: Data) {
        imageData = data
        guard let admin = SessionManager.shared.currentAdmin else { return }
        admin.imageData = data
        do {
            try viewContext.save()
            showSuccessAlert = true
        } catch {
            print("Error saving profile image: \(error.localizedDescription)")
        }
    }
    
    func updateProfile() -> Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanContact = contact.filter { $0.isNumber }
        
        guard !cleanName.isEmpty else {
            alertMessage = "Please enter your name."
            showAlert = true
            return false
        }
        
        guard isValidEmail(cleanEmail) else {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return false
        }
        
        guard cleanContact.count == 10 else {
            alertMessage = "Please enter a valid 10-digit contact number."
            showAlert = true
            return false
        }
        
        guard let admin = SessionManager.shared.currentAdmin else {
            alertMessage = "No logged in admin found."
            showAlert = true
            return false
        }
        
        admin.name = cleanName
        admin.email = cleanEmail
        admin.contact = cleanContact
        if !password.isEmpty {
            admin.password = password
        }
        
        do {
            try viewContext.save()
            populateFields()
            return true
        } catch {
            alertMessage = "Failed to update profile: \(error.localizedDescription)"
            showAlert = true
            return false
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}