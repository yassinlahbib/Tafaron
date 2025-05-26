//
//  UserSession.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 26/05/2025.
//

import Foundation


@MainActor
final class UserSession: ObservableObject {
    @Published var authUser: AuthDataResultModel? = nil
    @Published var dbUser: DBUser? = nil

    func load() async {
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = auth
            self.dbUser = try await UserManager.shared.getUser(userId: auth.uid)
        } catch {
            print("Erreur chargement user session :", error)
        }
    }

    func signOut() async {
        try? AuthenticationManager.shared.signOut()
        self.authUser = nil
        self.dbUser = nil
    }
}

