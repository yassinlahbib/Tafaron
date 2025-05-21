//
//  AuthenticationView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


/*
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}
*/

@MainActor
final class AuthenticationViewModel : ObservableObject {
    
    func signInGoogle() async throws {
        print("In signInGoogle")
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            NavigationLink{
                SignInEmailView(showSignInView: $showSignInView)
            } label:{
                Text("Connexion avec Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)){
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print("Pas facile")
                        print(error)
                    }
                }
                
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Connexion")
    }
}

#Preview {
    NavigationStack{
        AuthenticationView(showSignInView: .constant(false))
    }
}
