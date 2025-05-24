//
//  AuthenticationViewModel.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 21/05/2025.
//

import Foundation

/*
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}
*/

@MainActor
final class AuthenticationViewModel : ObservableObject {

    /*
    func signInGoogle() async throws {
        print("In signInGoogle")
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }*/
    
    func signInGoogle() async throws -> Bool {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
        do {
            
            _ = try await UserManager.shared.getUser(userId: authDataResult.uid)
            // DBUser existe déjà
            return true
        } catch {
            // DBUser n'existe pas encore -> demander un pseudo
            return false
        }
    }

}
