//
//  AuthViewModel.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import Foundation
import CoreData
import Combine

class AuthViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var contactNo = ""
    
    @Published var isLogin = true
    @Published var isPasswordVisible = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    var isValidEmail: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: trimmedEmail)
    }
    
    private var validCheck: Bool {
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isValidEmail else {
            return false        }
        if isLogin {
            return !cleanEmail.isEmpty && !cleanPassword.isEmpty
        } else {
            return !cleanEmail.isEmpty &&
            !cleanPassword.isEmpty &&
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !contactNo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    func handleAuth() {
        guard validCheck else {
            if !isValidEmail {
                alertMessage = "Please enter a valid email address."
            } else {
                alertMessage = "Please fill in all required fields."
            }
            showAlert = true
            
            return
        }
        if isLogin {
            loginAdmin()
        } else {
            registerAdmin()
        }
    }
    
    private func loginAdmin(){
        let fetchRequest: NSFetchRequest<Admin> = Admin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ && password == %@", email, password)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let loggedAdmin = results.first {
                SessionManager.shared.login(admin: loggedAdmin)
                clearFields()
            } else {
                alertMessage = "Invalid email and password"
                showAlert = true
            }
        } catch {
            alertMessage = "Error loggin in:\(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func registerAdmin(){
        let fetchRequest: NSFetchRequest<Admin> = Admin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let existing = try viewContext.fetch(fetchRequest)
            if !existing.isEmpty {
                alertMessage = "An account with this mail is already registered"
                showAlert = true
                return
            }
            
            let newAdmin = Admin(context: viewContext)
            newAdmin.id = UUID()
            newAdmin.email = email
            newAdmin.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            newAdmin.password = password.trimmingCharacters(in: .whitespacesAndNewlines)
            newAdmin.contact = contactNo.trimmingCharacters(in: .whitespacesAndNewlines)
            newAdmin.timestamp = Date()
            
            try viewContext.save()
            
            SessionManager.shared.login(admin: newAdmin)
            
            clearFields()
        } catch {
            alertMessage = "Failed to register admin: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func clearFields(){
        email = ""
        password = ""
        name = ""
        contactNo = ""
        isPasswordVisible = false
    }
}
