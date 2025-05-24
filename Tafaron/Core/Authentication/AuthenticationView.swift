//
//  AuthenticationView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift




struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    @State private var needsPseudo = false
    @State private var pseudo = ""
    @State private var authUser: AuthDataResultModel? //Contient le user juste inscrit (Pas encore dans Firestore)
    @State private var message: String?
    @State private var showEmailSheet = false //Contrôle l’affichage de la vue SignInEmailView en .sheet
    
    var body: some View {
        VStack {
            if needsPseudo, let user = authUser { //Si user inscrit mais pas encore de DBUser
                PseudoInputView(user: user, showSignInView: $showSignInView) //On affiche la demande de pseudo
            } else {
                Button {
                    showEmailSheet = true
                }
                label: {
                    Text("Connexion avec Email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showEmailSheet) {
                    //SignInEmailView retourne un AuthDataResult via callback
                    SignInEmailView(showSignInView: $showSignInView) { user in
                        Task {
                            let exists = try? await UserManager.shared.getUser(userId: user.uid)
                            // si user exist deja on le connecte
                            if exists != nil {
                                showSignInView = false
                            } else {
                                // user n'existe pas
                                authUser = user
                                needsPseudo = true
                            }
                            showEmailSheet = false
                        }
                    }
                }

                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                    Task {
                        do {
                            let exists = try await viewModel.signInGoogle()
                            if exists {
                                showSignInView = false
                            } else {
                                authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                                needsPseudo = true
                            }
                        } catch {
                            print("Erreur Connexion Google :", error)
                        }
                    }
                }

                Spacer()
            }
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
