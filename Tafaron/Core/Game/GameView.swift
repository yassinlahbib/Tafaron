//
//  GameView.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 23/05/2025.
//

import SwiftUI



struct PickerNombreJoueursSheet: View {
    @Binding var nombreJoueurs: Int
    var onValider: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Combien de joueurs ?")
                .font(.title2)
                .fontWeight(.medium)

            Picker("Nombre de joueurs", selection: $nombreJoueurs) {
                ForEach(4...6, id: \.self) { n in
                    Text("\(n)").tag(n)
                }
            }
            .pickerStyle(.segmented)

            Button("Valider") {
                onValider()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}



import SwiftUI

import SwiftUI

struct GameView: View {
    
    @StateObject private var viewModel = GameViewModel()
    @State private var nombreJoueurs: Int = 4
    @State private var showPlayerPicker = false
    @State private var maxSelection: Int? = nil // Dès qu’il n’est plus nil → go

    var body: some View {
        ZStack {
            // ✅ Si maxSelection est défini → on montre la SelectionAmisView
            if let max = maxSelection {
                SelectionAmisView(maxSelection: max)
            } else {
                // 💡 Sinon on montre le menu normal
                VStack(spacing: 24) {
                    if let pseudo = viewModel.user?.pseudo {
                        Text("Bonjour \(pseudo) 👋")
                            .font(.title2)
                    }

                    Button("Nouvelle Partie") {
                        showPlayerPicker = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)

                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showPlayerPicker) {
                    VStack(spacing: 24) {
                        Text("Combien de joueurs ?")
                            .font(.title2)

                        Picker("Nombre de joueurs", selection: $nombreJoueurs) {
                            ForEach(4...6, id: \.self) { n in
                                Text("\(n)").tag(n)
                            }
                        }
                        .pickerStyle(.segmented)

                        Button("Valider") {
                            Task {
                                maxSelection = nombreJoueurs - 1 //  Et hop, on change de vue
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    Task {
                        try? await viewModel.loadUser()
                    }
                }
            }
        }
    }
}





#Preview {
    GameView()
}
