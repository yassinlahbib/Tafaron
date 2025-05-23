//
//  CartesView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 22/05/2025.
//

import SwiftUI

final class CartesViewModel: ObservableObject {
    @Published private(set) var cartes: [Carte] = []

    init() {
        loadCartes()
    }

    private func loadCartes() {
        cartes = CartesDatabase.cartes
            .sorted {
                if $0.couleur == $1.couleur {
                    return $0.priorite < $1.priorite
                } else {
                    return $0.couleur < $1.couleur
                }
            }
    }
}


struct CartesView: View {
    @StateObject private var viewModel = CartesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.cartes) { carte in
                HStack(spacing: 16) {
                    Image(carte.imageName)
                        .resizable()
                        .frame(width: 50, height: 75)
                        .cornerRadius(5)
                    VStack(alignment: .leading) {
                        Text("\(carte.valeur) de \(carte.couleur)")
                            .font(.headline)
                        Text("Priorité : \(carte.priorite)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Jeu de cartes")
    }
}


#Preview {
    CartesView()
}
