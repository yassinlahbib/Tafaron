//
//  SignInEmailView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI



struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel() //Contient logique d'authentification
    @Binding var showSignInView: Bool //SAvoir si le user est connecté
    
    var onSignIn: ((AuthDataResultModel) -> Void)? //Quand un user se connecte ou s'inscrit on execute cette fonction en lui passant l'objet AuthDataResult -> Permet a la vue parent (AuthenticationView) de savoir qui vient de se connecter
    
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
            
            Button { //Bouton Connexion/Inscription
                Task {
                    do {
                        let authDataResult = try await viewModel.signUp() //Essaye de creer un nouveaux compte
                        onSignIn?(authDataResult) //Passe le user connecté a onSignIn
                        //showSignInView = false
                        //return
                    }catch{
                        print("Erreur signUp : ", error)
                        do {
                            let authDataResult = try await viewModel.signIn() //Si inscription echoue alors connexion
                            onSignIn?(authDataResult) //Passe le user connecté a onSignIn
                            //showSignInView = false
                            //return
                        } catch {
                            print("Erreur login : ", error)
                        }
                        
                    }
                    /*do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    }catch{
                        print(error)
                    }*/
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
