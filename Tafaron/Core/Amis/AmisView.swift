//
//  AmisView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 24/05/2025.
//

import Foundation
import FirebaseFirestore
import SwiftUI

@MainActor
final class DemandeAmisListener: ObservableObject {
    @Published var nombreDemandes: Int = 0
    private var listener: ListenerRegistration?

    func commencerEcoute(pseudo: String) {
        listener = FriendRequestManager.shared.listenForPendingRequests(for: pseudo) { [weak self] demandes in
            Task { @MainActor in
                self?.nombreDemandes = demandes.count
            }
        }
    }

    func arreter() {
        listener?.remove()
        listener = nil
    }
}




@MainActor
final class AmisViewModel: ObservableObject {
    
    //@Published var amis: [DBUser] = []
    @Published var amisTabPseudo: [String] = []
    
    func loadAmis() async throws {
        print("Chargement des amis")
        let auth = try AuthenticationManager.shared.getAuthenticatedUser()
        let currentUser = try await UserManager.shared.getUser(userId: auth.uid)
        
        //guard let amisIds = currentUser.amis else  {
        //    amis = []
        //    return
        //}
        //var users: [DBUser] = []
        
        var amisTab: [String] = []
        guard let amis = currentUser.amis else {
            return
        }
        for pseudo in amis {
            amisTab.append(pseudo)
        }
        self.amisTabPseudo = amisTab
    }
    
    
    func supprimerAmi(pseudo: String) async {
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            let currentUser = try await UserManager.shared.getUser(userId: auth.uid)
            
            guard let userPseudo = currentUser.pseudo else { return }

            try await UserManager.shared.removeFriendBetween(pseudo1: userPseudo, pseudo2: pseudo)

            // Mise à jour UI locale
            await MainActor.run {
                self.amisTabPseudo.removeAll { $0 == pseudo } //Supprime tous les éléments du tableau dont le pseudo correspond à celui qu'on vient de retirer
            }
        } catch {
            print("❌ Erreur suppression ami :", error)
        }
    }

    

}



struct AmisView: View {
    
    @StateObject private var viewModel = AmisViewModel()
    
    @StateObject private var demandeListener = DemandeAmisListener()
    @State private var currentUser: String? = nil
    
    
    var body: some View {
        
        Text("Tu as \(demandeListener.nombreDemandes) demandes en attente")
            .font(.subheadline)
            .foregroundColor(.blue)

        List {
            ForEach(viewModel.amisTabPseudo, id: \.self) { pseudo in
                Text(pseudo)
                    .font(.headline)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.supprimerAmi(pseudo: pseudo)
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
        }



        .navigationTitle("Mes amis")
                .task {
                    do {
                        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                        let DBUser = try await UserManager.shared.getUser(userId: authUser.uid)
                        try await viewModel.loadAmis()
                        
                        if let pseudo = DBUser.pseudo {
                            demandeListener.commencerEcoute(pseudo: pseudo)
                        }
                        
                    } catch {
                        print("Erreur chargement amis :", error)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            DemandeAmisView(demandeListener: demandeListener)
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "plus")
                                    .font(.headline)
                                
                                if demandeListener.nombreDemandes > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        do {
                            try await viewModel.loadAmis()
                        } catch {
                            print("Erreur rechargement amis :", error)
                        }
                    }
                }

            }
        }


#Preview {
    AmisView()
}
