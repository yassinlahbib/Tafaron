//
//  PseudoInputView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 24/05/2025.
//

import SwiftUI

struct PseudoInputView: View {
    
    let user: AuthDataResultModel // L'utilisateur qui vient de s'inscrire (mais qui n’a pas encore de pseudo enregistré dans Firestore)
    @Binding var showSignInView: Bool //  Ce Binding permet de fermer l'écran de connexion une fois le pseudo validé
    
    @State private var pseudo: String = ""
    @State private var message: String? // Message d’erreur affiché si le pseudo est déjà pris ou en cas d’erreur technique
    
    var body: some View {
        VStack (spacing: 16) {
            Text("Choisis un pseudo")
                .font(.title2)
                .bold()
            TextField("Pseudo", text: $pseudo)
                .textFieldStyle(.roundedBorder)
            Button ("Valider"){
                Task{
                    do{
                        let disponible = try await UserManager.shared.isPseudoDisponible(pseudo) // Vérifie si ce pseudo est déjà utilisé dans Firestore
                        if !disponible {
                            message = "Ce pseudo est deja pris !"
                            return
                        }
                        
                        // Pseudo disponible
                        let dbUser = DBUser(auth: user, pseudo: pseudo) //On créér un DBUser avec le pseudo et les info du user
                        try await UserManager.shared.createNewUser(user: dbUser) //On l'enregistre dans Firestore
                        showSignInView = false // On ferme la vue de connexion
                    } catch {
                        message = "Erreur: \(error.localizedDescription)"
                    }
                }
            }
            if let message = message {
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .padding()
        
    }
}


#Preview {
    NavigationStack {
        let mockUser = AuthDataResultModel(
            uid: "123456",
            email: "test@example.com",
            photoUrl: nil
        )
        PseudoInputView(user: mockUser, showSignInView: .constant(false))
    }
}
