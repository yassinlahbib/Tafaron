//
//  SettingsView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI



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
            Button(role: .destructive){
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Supprimer le compte")
            }
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
        }
        .onAppear() {
            viewModel.loadAuthProviders()
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
