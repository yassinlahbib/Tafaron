//
//  SelectionAmisView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 26/05/2025.
//

import SwiftUI

@MainActor
final class SelectionAmisViewModel: ObservableObject {
    @Published var amis: [String] = []
    @Published var selection: Set<String> = []
    @Published var errorMessage: String? = nil
    
    func loadAmis() async {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let dbUser = try await UserManager.shared.getUser(userId: authUser.uid)
            self.amis = dbUser.amis ?? []
        } catch {
            errorMessage = "Erreur lors du chargement des amis : \(error.localizedDescription)"
        }
    }

    func creerGameAvecAmis(maxSelection: Int) async {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let userId = authUser.uid

            let dbUser = try await UserManager.shared.getUser(userId: userId)

            // Récupère les pseudos des amis sélectionnés
            let pseudos = Array(selection)

            // Transforme les pseudos en ID Firebase
            let ids = try await withThrowingTaskGroup(of: String?.self) { group -> [String] in
                for pseudo in pseudos {
                    group.addTask {
                        let user = try? await UserManager.shared.getUserByPseudo(userPseudo: pseudo)
                        return user?.userId
                    }
                }

                var result: [String] = []
                for try await id in group {
                    if let id = id {
                        result.append(id)
                    }
                }
                return result
            }

            // Ajoute le maître du jeu
            let allIds = [userId] + ids

            let game = Game(
                maitreGame: userId,
                nbPersonnes: allIds.count,
                idPersonnes: allIds,
                manches: []
            )

            
            try await GameManager.shared.createGame(game: game)
            //try await GameManager.shared.gameDocument(idGame: game.idGame).setData(from: game)
            print("Game créée avec les joueurs:", allIds)

        } catch {
            errorMessage = "Erreur création de partie : \(error.localizedDescription)"
        }
    }
}

struct SelectionAmisView: View {
    let maxSelection: Int
    @StateObject private var viewModel = SelectionAmisViewModel()

    var body: some View {
        VStack {
            Text("Sélectionne jusqu'à \(maxSelection) amis")
                .font(.headline)

            List(viewModel.amis, id: \.self) { pseudo in
                HStack {
                    Text(pseudo)
                    Spacer()
                    if viewModel.selection.contains(pseudo) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if viewModel.selection.contains(pseudo) {
                        viewModel.selection.remove(pseudo)
                    } else if viewModel.selection.count < maxSelection {
                        viewModel.selection.insert(pseudo)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top)
            }

            Button("Valider") {
                Task {
                    await viewModel.creerGameAvecAmis(maxSelection: maxSelection)
                }
            }
            .disabled(viewModel.selection.isEmpty)
            .padding()
        }
        .onAppear {
            Task {
                await viewModel.loadAmis()
            }
        }
    }
}



#Preview {
    SelectionAmisView(maxSelection: 4)
}


