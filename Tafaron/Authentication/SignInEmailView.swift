//
//  SignInEmailView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI

final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    // Inscription
    func signUp() async throws {
        //S'assurer que les variables ne sont pas vide
        guard !email.isEmpty, !password.isEmpty else {
            print("Email ou Mot de passe non trouvés.")
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    // Connexion
    func signIn() async throws {
        //S'assurer que les variables ne sont pas vide
        guard !email.isEmpty, !password.isEmpty else {
            print("Email ou Mot de passe non trouvés.")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Mot de passe", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    }catch{
                        print(error)
                    }
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    }catch{
                        print(error)
                    }
                }
                
            } label: {
                Text("Connexion avec Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                
            }
            Spacer()
            
        }
        
        .padding()
        .navigationTitle("Connexion avec Email")
    }
}

#Preview {
    NavigationStack{
        SignInEmailView(showSignInView: .constant(false))
    }
    
}
