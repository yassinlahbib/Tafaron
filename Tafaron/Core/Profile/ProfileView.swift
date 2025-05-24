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
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremium(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavoriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        Task {
            try await UserManager.shared.addFavoriteMovie(userId: user.userId, movie: movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavoriteMovie() {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeFavoriteMovie(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
}

struct ProfileView: View { //Vue pour chaque profile
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool // la vue reçoit un lien vers une variable externe pour savoir si on affiche la vue de connexion ou non
    let preferenceOptions: [String] = ["Sports", "Films", "Livres"]
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    
    var body: some View {
        List {
            if let user = viewModel.user { // Si user est chargé on affiche son id
                Text("User Id: \(user.userId)")
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                VStack{
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { string in
                            Button(string) {
                                if preferenceIsSelected(text: string) {
                                    viewModel.removeUserPreference(text: string)
                                } else {
                                    viewModel.addUserPreference(text: string)
                                }
                                
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(text: string) ? .green : .red)
                        }
                    }
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button {
                    if user.favoriteMovie == nil {
                        viewModel.addFavoriteMovie()
                    } else {
                        viewModel.removeFavoriteMovie()
                    }
                } label: {
                    Text("Favorite Movie: \((user.favoriteMovie?.title ?? ""))" )
                }
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
    RootView()
}


