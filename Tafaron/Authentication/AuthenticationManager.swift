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
    
    //Déconnexion
    func signOut() throws { //Se deconnecte localement donc pas besoin de async
        try Auth.auth().signOut()
    }
    
}
