//
//  GameView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 23/05/2025.
//

import SwiftUI


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

struct GameView: View {
    
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        VStack {
            if let pseudo = viewModel.user?.pseudo {
                Text("Bonjour \(pseudo.isEmpty ? "utilisateur" : pseudo) 👋")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
            }

            
            Button {
                print("Bouton préssé !")
                Task {
                    do {
                        //let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                        let game = try await viewModel.createGame()
                        print("Game créée avec ID :", game.id)
                        // Naviguer vers l'écran de salle d'attente
                    } catch {
                        print("Erreur création de partie :", error)
                    }
                }
                } label: {
                    Text("Nouvelle Partie")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .onAppear {
                Task {
                    try? await viewModel.loadUser()
                }
            }

        }
    }


#Preview {
    GameView()
}
