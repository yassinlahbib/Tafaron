//
//  GameManager.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 23/05/2025.
//

import Foundation
import FirebaseFirestore

struct Manche: Codable {
    let id: String
    let idGame: String
    let nomManche: String
    let mains: [String: [Carte]] // a chaque joueur on associe les cartes en sa possession
    
}

struct Game : Codable {
    let id: String
    let date: Date
    let maitreGame: String //L'id du joueurs qui a crée la Game
    let nbPersonnes: Int
    let idPersonnes: [String] //Tableau des id des joueurs
    let manches: [Manche] //Plusieurs manches (Plis, Coeur, Dames, ..)
    
}


final class GameManager {
    
    static let shared = GameManager()
    private init () {}
    
    private let gameCollection = Firestore.firestore().collection("games")
    
    private func gameDocument(gameId: String) -> DocumentReference {
        gameCollection.document(gameId)
    }
    
    
    func createGame(userId: String) async throws -> Game {
        let gameId = UUID().uuidString
        let date = Date()
        
        let game = Game(
            id: gameId,
            date: date,
            maitreGame: userId,
            nbPersonnes: 1,
            idPersonnes: [userId],
            manches: []
        )
        
        try gameDocument(gameId: gameId).setData(from: game)
        return game
    }
}
