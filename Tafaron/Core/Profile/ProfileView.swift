//
//  ProfileView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 21/05/2025.
//

import SwiftUI

@MainActor // Le changement d'etat (@Published) se fait sur le thread principal
final class ProfileViewModel: ObservableObject { //ObservableObject: permet a swiftUI de réagir automatiquement au changement de user
    
    @Published private(set) var user: DBUser? = nil
    // @Published : quand user change, la vue est recalculée
    // private(set) : la vue peut lire user, mais seul le ViewModel peut le modifier
    
    // Récupérer l’utilisateur courant (local, pas réseau)
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct ProfileView: View { //Vue pour chaque profile
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool // la vue reçoit un lien vers une variable externe pour savoir si on affiche la vue de connexion ou non
    
    var body: some View {
        List {
            if let user = viewModel.user { // Si user est chargé on affiche son id
                Text("UserId: \(user.userId)")
            }
        }
        .task { // Au chargement de la page on essaye de charger l'utilisateur courant
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar { //Bouton d'action pour acceder a SettingsView via un bouton d'action
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
