//
//  PseudoInputView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 24/05/2025.
//

import SwiftUI

struct PseudoInputView: View {
    let user: AuthDataResultModel
    @Binding var showSignInView: Bool
    
    @State private var pseudo: String = ""
    @State private var message: String?
    
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
                        let disponible = try await UserManager.shared.isPseudoDisponible(pseudo)
                        if !disponible {
                            message = "Ce pseudo est deja pris !"
                            return
                        }
                        
                        let dbUser = DBUser(auth: user, pseudo: pseudo)
                        try await UserManager.shared.createNewUser(user: dbUser)
                        showSignInView = false
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
