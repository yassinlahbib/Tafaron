//
//  TabbarView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 23/05/2025.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            NavigationStack {
                GameView()
            }
            .tabItem{
                Image(systemName: "gamecontroller")
                Text("Jeux")
            }
            NavigationStack {
                AmisView()
            }
            .tabItem{
                Image(systemName: "person.3")
                Text("Amis")
            }
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem{
                Image(systemName: "person")
                Text("Profile")
            }
        }
    }
}
#Preview {
    TabbarView(showSignInView: .constant(false))
}
