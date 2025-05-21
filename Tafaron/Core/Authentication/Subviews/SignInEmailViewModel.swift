//
//  SignInEmailViewModel.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 21/05/2025.
//

import Foundation

final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    // Inscription
    func signUp() async throws {
        //S'assurer que les variables ne sont pas vide
        guard !email.isEmpty, !password.isEmpty else {
            print("Email ou Mot de passe non trouvés.")
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, photUrl: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user)
    }
    
    // Connexion
    func signIn() async throws {
        //S'assurer que les variables ne sont pas vide
        guard !email.isEmpty, !password.isEmpty else {
            print("Email ou Mot de passe non trouvés.")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
