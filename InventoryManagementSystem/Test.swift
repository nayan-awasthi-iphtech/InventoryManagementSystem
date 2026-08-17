//
//  Test.swift
//  InventoryManagementSystem
//
//  Created by iPHTech 30 on 17/08/26.
//

import SwiftUI

struct Test: View {
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.blue,.green,.red]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack{
                Text("Welcome")
                
                Button(){
                    
                } label: {
                    Text("Logout")
                }
            }
            .background(Color(.systemCyan).opacity(0.5))
        }
    }
}

#Preview {
    Test()
}
