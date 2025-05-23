//
//  CartesDatabase.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 22/05/2025.
//

import Foundation


struct Carte: Identifiable, Codable{
    let id: String        // ex : "KH"
    let valeur: String    // ex : "Roi"
    let couleur: String   // ex : "Cœur"
    let priorite: Int
    let imageName: String

}


final class CartesDatabase {
    
    static let cartes: [Carte] = {
        let couleurs = [
            ("Coeur", "H"),
            ("Carreau", "D"),
            ("Trèfle", "C"),
            ("Pique", "S")
        ]
        
        let valeurs: [(String, String, Int)] = [
            ("As", "A", 12),
            ("2", "2", 0),
            ("3", "3", 1),
            ("4", "4", 2),
            ("5", "5", 3),
            ("6", "6", 4),
            ("7", "7", 5),
            ("8", "8", 6),
            ("9", "9", 7),
            ("10", "0", 8), // "0" = nom utilisé dans l'API DeckOfCards
            ("Valet", "J", 9),
            ("Dame", "Q", 10),
            ("Roi", "K", 11)
        ]
        
        var cartes: [Carte] = []
        
        for (nomCouleur, codeCouleur) in couleurs {
            for (nomValeur, codeValeur, priorite) in valeurs {
                let id = "\(codeValeur)\(codeCouleur)"    // ex: "KH"
                let carte = Carte(
                    id: id,
                    valeur: nomValeur,
                    couleur: nomCouleur,
                    priorite: priorite,
                    imageName: id // correspond au nom dans Assets
                )
                cartes.append(carte)
            }
        }
        
        return cartes
    }()
}
