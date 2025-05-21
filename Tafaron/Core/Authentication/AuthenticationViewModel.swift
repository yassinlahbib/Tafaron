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
    
    func signInGoogle() async throws {
        print("In signInGoogle")
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, photUrl: authDataResult.photoUrl, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user)
    }
    
}
