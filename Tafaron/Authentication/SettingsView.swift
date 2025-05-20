//
//  SettingsView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI

@MainActor
final class SettingsViewModel : ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    func resetPassword() async throws {
        let authUser = try  AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Déconnexion"){
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
                
            }
            emailSection
        }
        .navigationBarTitle("Réglages")
    }
}

#Preview {
    NavigationStack{
        SettingsView(showSignInView: .constant(true))
    }
    
}

extension SettingsView {
    private var emailSection: some View {
        Section{
            Button("Réinitialiser Mot de Passe") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET !")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Fonctionnalité Mot de Passe")
        }
    }
    
}
