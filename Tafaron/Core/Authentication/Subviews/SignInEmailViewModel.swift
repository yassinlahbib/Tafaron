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
    func signUp() async throws -> AuthDataResultModel {
        //S'assurer que les variables ne sont pas vide
        guard !email.isEmpty, !password.isEmpty else {
            print("Email ou Mot de passe non trouvés.")
            throw URLError(.badURL)
        }
        
        return try await AuthenticationManager.shared.createUser(email: email, password: password)
        // On ne creer pas le DBUser ici car on doit lui associer un pseudo
        
        //let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        //let user = DBUser(auth: authDataResult)
        // try await UserManager.shared.createNewUser(user: user)
    }
    
    // Connexion
    func signIn() async throws -> AuthDataResultModel {
        //S'assurer que les variables ne sont pas vide
        guard !email.isEmpty, !password.isEmpty else {
            print("Email ou Mot de passe non trouvés.")
            throw URLError(.badURL)
        }
        return try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
