//
//  RootView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 19/05/2025.
//

import SwiftUI

struct RootView: View {
    
    //variable controle si 'écran de connexion doit s'afficher
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                Text ("Réglages")
            }
        }
        .onAppear{ //Quand la vue apparait a l'écran, on verifie si l'utilisateur est connecté
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() // renvoie nil ou userFirebase
            self.showSignInView = authUser == nil // si nil on montre ecran de connexion
        }
        .fullScreenCover(isPresented: $showSignInView){ //Si imshow a True On montre AuthenticationView
            NavigationStack {
                AuthenticationView()
            }
        }
    }
}

#Preview {
    RootView()
}
