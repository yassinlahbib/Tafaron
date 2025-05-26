//
//  GameManager.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 23/05/2025.
//

import Foundation
import FirebaseFirestore

struct Manche: Codable {
    let idManche: String
    let idGame: String
    let nomManche: String
    let mains: [String: [Carte]] // a chaque joueur on associe les cartes en sa possession
    
}

struct Game : Codable {
    let idGame: String
    let date: Date
    let maitreGame: String //L'id du joueurs qui a crée la Game
    let nbPersonnes: Int
    let idPersonnes: [String] //Tableau des id des joueurs
    let manches: [Manche] //Plusieurs manches (Plis, Coeur, Dames, ..)
    
    //Constructeur
    init(idGame: String = UUID().uuidString,
         date: Date = Date(),
         maitreGame: String,
         nbPersonnes: Int,
         idPersonnes: [String],
         manches: [Manche]) {
        
        self.idGame = idGame
        self.date = date
        self.maitreGame = maitreGame
        self.nbPersonnes = nbPersonnes
        self.idPersonnes = idPersonnes
        self.manches = manches
    }
    
    enum CodingKeys: String, CodingKey {
        case idGame = "id_game"
        case date = "date_game"
        case maitreGame = "maitre_game"
        case nbPersonnes = "nb_personnes"
        case idPersonnes = "id_personnes"
        case manches = "manches"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.idGame = try container.decode(String.self, forKey: .idGame)
        self.date = try container.decode(Date.self, forKey: .date)
        self.maitreGame = try container.decode(String.self, forKey: .maitreGame)
        self.nbPersonnes = try container.decode(Int.self, forKey: .nbPersonnes)
        self.idPersonnes = try container.decode([String].self, forKey: .idPersonnes)
        self.manches = try container.decode([Manche].self, forKey: .manches)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.idGame, forKey: .idGame)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.maitreGame, forKey: .maitreGame)
        try container.encode(self.nbPersonnes, forKey: .nbPersonnes)
        try container.encode(self.idPersonnes, forKey: .idPersonnes)
        try container.encode(self.manches, forKey: .manches)
    }
}


final class GameManager {
    
    static let shared = GameManager()
    private init () {}
    
    private let gameCollection = Firestore.firestore().collection("games")
    
    private func gameDocument(idGame: String) -> DocumentReference {
        gameCollection.document(idGame)
    }
    
    
    func createGame(userId: String) async throws -> Game {
        let idGame = UUID().uuidString
        let date = Date()
        
        let game = Game(
            idGame : idGame,
            date: date,
            maitreGame: userId,
            nbPersonnes: 1,
            idPersonnes: [userId],
            manches: []
        )
        
        try gameDocument(idGame: idGame).setData(from: game)
        return game
    }
    
    func createGame(game: Game) async throws -> Game {
        
        let idGame = UUID().uuidString
        let date = Date()
        
        let game = Game(
            idGame : idGame,
            date: date,
            maitreGame: game.maitreGame,
            nbPersonnes: game.nbPersonnes,
            idPersonnes: game.idPersonnes,
            manches: []
        )
        
        try gameDocument(idGame: idGame).setData(from: game)
        return game
    }

}
