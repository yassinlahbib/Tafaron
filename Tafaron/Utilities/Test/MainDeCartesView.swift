//
//  MainDeCartesView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 22/05/2025.
//

import SwiftUI


struct DemoMainView: View {
    let toutesLesCartes = CartesDatabase.cartes.shuffled()
    
    var body: some View {
        VStack {
            Text("Main du joueur")
                .font(.headline)
            MainDeCartesView(main: Array(toutesLesCartes.prefix(13)))
        }
    }
}


struct MainDeCartesView: View {
    let main: [Carte]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -20) { // -20 pour effet "en éventail"
                ForEach(main) { carte in
                    Image(carte.imageName)
                        .resizable()
                        .frame(width: 60, height: 90)
                        .cornerRadius(4)
                        .shadow(radius: 2)
                }
            }
            .padding()
        }
    }
}




#Preview {
    DemoMainView()
}
