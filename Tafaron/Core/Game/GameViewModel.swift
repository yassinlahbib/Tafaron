//
//  GameViewModel.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 24/05/2025.
//

import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    func createGame() async throws -> Game {
        guard let user = user else {
            throw URLError(.userAuthenticationRequired)
        }
        return try await GameManager.shared.createGame(userId: user.userId)
    }
    
    func loadUser() async throws {
        let auth = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: auth.uid)
    }


}
