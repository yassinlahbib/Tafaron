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
            guard let destinataire = try? await UserManager.shared.getUserByPseudo(userPseudo: to) else {
                messageErreur = "Aucun utilisateur avec ce pseudo."
                return
            }

            if destinataire.pseudo == from {
                messageErreur = "Tu ne peux pas t’ajouter toi-même."
                return
            }

            try await FriendRequestManager.shared.sendFriendRequest(
                from: from,
                to: destinataire.pseudo!
            )
            messageErreur = "Demande envoyée à \(to) !"

        } catch {
            messageErreur = "Erreur: \(error.localizedDescription)"
        }
    }

    func commencerEcouteDesDemandes(pseudoId: String) {
        listener = FriendRequestManager.shared.listenForPendingRequests(for: pseudoId) { [weak self] demandes in
            Task { @MainActor in
                self?.demandesRecues = demandes
            }
        }
    }
    
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
    @State private var messageAction: String? = nil
    var demandeListener: DemandeAmisListener

    var body: some View {
        VStack(spacing: 12) {
            TextField("Pseudo à ajouter", text: $pseudoRecherche)
                .textFieldStyle(.roundedBorder)

            Button("Envoyer demande") {
                Task {
                    if let userPseudo = viewModel.user?.pseudo {
                        await viewModel.envoyerDemande(from: userPseudo, to: pseudoRecherche)
                    }
                }
            }

            if let message = viewModel.messageErreur {
                Text(message)
                    .foregroundColor(.red)
            }

            if let actionMessage = messageAction {
                Text(actionMessage)
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .transition(.opacity)
            }

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.demandesRecues, id: \.friendRequestId) { demande in
                        HStack {
                            Text(demande.from)
                                .font(.headline)

                            Spacer()

                            Button {
                                Task {
                                    await viewModel.refuserDemande(demande: demande)
                                    await MainActor.run {
                                        withAnimation {
                                            viewModel.demandesRecues.removeAll { $0.friendRequestId == demande.friendRequestId }
                                            messageAction = "❌ Demande refusée de \(demande.from)"
                                        }
                                    }
                                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                                    await MainActor.run {
                                        withAnimation {
                                            messageAction = nil
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Circle().stroke(Color.red, lineWidth: 1.5))
                            }

                            Button {
                                Task {
                                    await viewModel.accepterDemande(demande: demande)
                                    await MainActor.run {
                                        withAnimation {
                                            viewModel.demandesRecues.removeAll { $0.friendRequestId == demande.friendRequestId }
                                            messageAction = "✅ Demande acceptée de \(demande.from)"
                                        }
                                    }
                                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                                    await MainActor.run {
                                        withAnimation {
                                            messageAction = nil
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.green)
                                    .padding(8)
                                    .background(Circle().stroke(Color.green, lineWidth: 1.5))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .onAppear {
            Task {
                try? await viewModel.loadUser()
                if let userPseudo = viewModel.user?.pseudo {
                    viewModel.commencerEcouteDesDemandes(pseudoId: userPseudo)
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
