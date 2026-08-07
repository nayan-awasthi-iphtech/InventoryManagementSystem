//
//  SessionManager.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 06/08/26.
//

import Foundation
import CoreData
import Combine

final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentAdmin: Admin?
    @Published var isLoggedIn: Bool = false
    
    private let loggedInAdminKey = "LoggedInAdminID"
    private let viewContext = PersistenceController.shared.container.viewContext
    
    private init(){
        restoreSession()
    }
    
    func login(admin:Admin){
        self.currentAdmin = admin
        self.isLoggedIn = true
        
        if let adminId = admin.id {
            UserDefaults.standard.set(adminId.uuidString, forKey: loggedInAdminKey)
        }
    }
    
    func logout(){
        self.currentAdmin = nil
        self.isLoggedIn = false
        
        UserDefaults.standard.removeObject(forKey: loggedInAdminKey)
    }
    
    private func restoreSession(){
        guard let savedUUIDString = UserDefaults.standard.string(forKey: loggedInAdminKey),
              let adminUUID = UUID(uuidString: savedUUIDString) else {
            self.isLoggedIn = false
            return
        }
        let request: NSFetchRequest<Admin> = Admin.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", adminUUID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let fetchedAdmin = results.first {
                self.currentAdmin = fetchedAdmin
                self.isLoggedIn = true
            } else {
                logout()
            }
        } catch {
            print("Failed to fetch logged-in admin: \(error.localizedDescription)")
            logout()
        }
    }
}
