//
//  AuthenticationManager.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import Foundation
import FirebaseAuth

// Structure de donnée d'un utilisateur
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    
}

final class AuthenticationManager {
    //Patron de Conception : Singleton
    
    static let shared = AuthenticationManager()
    private init() {}
    
    //Récuperation compte utilisateur a l'ouverture de l'app
    func getAuthenticatedUser() throws -> AuthDataResultModel { // Pas de async ici (Va vérifier l'authentification du user en local, car si existant est enregistré dans leSDK localement - Ne contacte pas le serveur)
        guard let user = Auth.auth().currentUser else { //Vérifie si l'utilisateur à un compte
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // google.com
    // password
    
    func getProviders() throws -> [AuthProviderOption]{
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    //Déconnexion
    func signOut() throws { //Se deconnecte localement donc pas besoin de async
        try Auth.auth().signOut()
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
    
}

//MARK: SIGN IN EMAIL
extension AuthenticationManager {
    //Création utilisateur
    @discardableResult //la fonction retourne une valeur que l'on utilise pas tout le temps
    func createUser(email: String, password: String) async throws -> AuthDataResultModel { //async (va essayer d'atteindre le serveur Firebase)
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    //Connexion
    @discardableResult //la fonction retourne une valeur que l'on utilise pas tout le temps
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // Reset Mot de Passe
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}


//MARK: SIGN IN SSO
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
