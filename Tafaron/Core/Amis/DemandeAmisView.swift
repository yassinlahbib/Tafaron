//
//  DemandeAmisView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 24/05/2025.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
final class DemandeAmisViewModel: ObservableObject {
    
    @Published var demandesRecues: [FriendRequest] = []
    @Published var messageErreur: String?
    @Published private(set) var user: DBUser? = nil
    
    private var listener: ListenerRegistration?
    
    
    func envoyerDemande(from: String, to: String) async {
        do {
            // On récupere le DBUser du destinataire
            guard let destinataire = try? await UserManager.shared.getUserByPseudo(userPseudo: to) else {
                messageErreur = "Aucun utilisateur avec ce pseudo."
                print("Aucun user find !")
                return
            }

            if destinataire.pseudo == from {
                messageErreur = "Tu ne peux pas t’ajouter toi-même."
                print("demande a lui meme pas possible")
                return
            }

            try await FriendRequestManager.shared.sendFriendRequest(
                from: from,
                to: destinataire.pseudo!
            )
            print(from, "a resussi a envoyer a", to)
            messageErreur = "Demande envoyée à \(to) !"

        } catch {
            messageErreur = "Erreur: \(error.localizedDescription)"
        }
    }
    


    
    
    // Commencer à écouter les demandes en attente
    func commencerEcouteDesDemandes(pseudoId: String) {
        listener = FriendRequestManager.shared.listenForPendingRequests(for: pseudoId) { [weak self] demandes in
            Task { @MainActor in
                self?.demandesRecues = demandes
            }
        }
    }
    
    // Stopper le listener
    func arreterEcoute() {
        listener?.remove()
        listener = nil
    }
    
    func loadUser() async throws {
        let auth = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: auth.uid)
    }
    
    func accepterDemande(demande: FriendRequest) async {
        do {
            try await FriendRequestManager.shared.accepterDemande(demande)
        } catch {
            messageErreur = "Erreur lors de l'acceptation : \(error.localizedDescription)"
        }
    }

    func refuserDemande(demande: FriendRequest) async {
        do {
            try await FriendRequestManager.shared.refuserDemande(demande)
        } catch {
            messageErreur = "Erreur lors du refus : \(error.localizedDescription)"
        }
    }

    
    
}


struct DemandeAmisView: View {
    @StateObject private var viewModel = DemandeAmisViewModel()
    @State private var pseudoRecherche = ""
    var demandeListener: DemandeAmisListener
    //@State private var currentUserId: String? = nil

    var body: some View {
        VStack {
            TextField("Pseudo à ajouter", text: $pseudoRecherche)
                .textFieldStyle(.roundedBorder)

            Button("Envoyer demande") {
                Task {
                    if let userPseudo = viewModel.user?.pseudo {
                        print(userPseudo, "envoie demande a :", pseudoRecherche)
                        await viewModel.envoyerDemande(from: userPseudo, to: pseudoRecherche)
                    }
                }
            }

            if let message = viewModel.messageErreur {
                Text(message)
                    .foregroundColor(.red)
            }
            

        
            List {
                ForEach(viewModel.demandesRecues, id: \.friendRequestId) { demande in
                    HStack {
                        Text(demande.from)
                            .font(.headline)

                        Spacer()

                        Button {
                            Task {
                                await viewModel.refuserDemande(demande: demande)
                                print("")
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Circle().stroke(Color.red, lineWidth: 1.5))
                        }
                        Spacer()
                        Button {
                            Task {
                                await viewModel.accepterDemande(demande: demande)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Circle().stroke(Color.green, lineWidth: 1.5))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            
        }
        .padding()
        .onAppear {
            Task {
                try? await viewModel.loadUser()
                if let userPseudo = viewModel.user?.pseudo {
                    viewModel.commencerEcouteDesDemandes(pseudoId: userPseudo)
                    print("pseudo connecté est celui de :", userPseudo)
                } else {
                    viewModel.messageErreur = "Impossible de récupérer l'identifiant utilisateur."
                }
            }
        }
        .onDisappear {
            viewModel.arreterEcoute()
        }
    }
}



#Preview {
    DemandeAmisView(demandeListener: DemandeAmisListener())
}

