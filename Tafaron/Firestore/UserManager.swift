//
//  UserManager.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 21/05/2025.
//

import Foundation
import FirebaseFirestore

struct Movie : Codable{
    let id: String
    let title: String
    let isPopular: Bool
}

struct DBUser: Codable {
    
    //Propriété de l'utilisateur
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    let pseudo: String?
    let amis: [String]? //Liste des amis du user

    
    
    //Constructeur à partir de l'authentification -> Création d'un DBUser au moment de l'inscription
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.preferences = nil
        self.favoriteMovie = nil
        self.pseudo = nil
        self.amis = nil
    }
    
    //Constructeur pour ajouter le pseudo au DBUser
    init(auth: AuthDataResultModel, pseudo: String) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.preferences = nil
        self.favoriteMovie = nil
        self.pseudo = pseudo
        self.amis = nil
    }

     
    //Constructeur manuel
    init (
    userId: String,
    email: String? = nil,
    photoUrl: String? = nil,
    dateCreated: Date? = nil,
    isPremium: Bool? = nil,
    preferences: [String]? = nil,
    favoriteMovie: Movie? = nil,
    pseudo: String? = nil,
    amis: [String]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
        self.pseudo = pseudo
        self.amis = amis
    }
    
    //Définition des noms exacts des champs Firestore
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "user_isPremium"
        case preferences = "preferences"
        case favoriteMovie = "favorite_movie"
        case pseudo = "pseudo"
        case amis = "amis"

    }
    
    //Recrée un DBUser à partir d’un document Firestore. (Généré par XCODE)
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favoriteMovie = try container.decodeIfPresent(Movie.self, forKey: .favoriteMovie)
        self.pseudo = try container.decodeIfPresent(String.self, forKey: .pseudo)
        self.amis = try container.decodeIfPresent([String].self, forKey: .amis)
    }
    
    //Transforme un DBUser en dictionnaire Firestore, prêt à être enregistré. (Généré par XCODE)
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favoriteMovie, forKey: .favoriteMovie)
        try container.encodeIfPresent(self.pseudo, forKey: .pseudo)
        try container.encodeIfPresent(self.amis, forKey: .amis)
    }
}


final class UserManager {
    
    //Classe Singleton (shared) qui centralise tous les accès à la collection "users".
    static let shared = UserManager()
    private init () { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    //Récupérer une référence vers un document utilisateur via l'id
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    //Récupérer une référence vers un document utilisateur via champs pseudo
    private func userDocumentByPseudo(userPseudo: String) async throws -> DBUser? {
        let snapshot = try await userCollection
            .whereField(DBUser.CodingKeys.pseudo.rawValue, isEqualTo: userPseudo)
            .getDocuments()
        guard let document = snapshot.documents.first else {
            return nil
        }
        return try document.data(as: DBUser.self)
    }
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    
    
    
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    
    
    
    
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func getUserByPseudo(userPseudo: String) async throws -> DBUser? {
        try await userDocumentByPseudo(userPseudo: userPseudo)
    }
    

    //Mettre à jour uniquement le champ isPremium
    func updateUserPremium(userId: String, isPremium: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    
    //Ajouter des préférences a l'utilisateur
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference]) //Union de ce qu'il y a vait dans l'array et ce qu'on ajoute comme preference
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    //Supprimer des préférences a l'utilisateur
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference]) //Union de ce qu'il y a vait dans l'array et ce qu'on ajoute comme preference
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    
    
    
    //Ajouter un film favori a l'utilisateur
    func addFavoriteMovie(userId: String, movie: Movie) async throws {
        guard let data = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        
        let dict: [String:Any] = [
            DBUser.CodingKeys.favoriteMovie.rawValue : data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    
    
    //Supprimer un film favori a l'utilisateur
    func removeFavoriteMovie(userId: String) async throws {
        let data: [String:Any?] = [
            DBUser.CodingKeys.favoriteMovie.rawValue : nil 
        ]
        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
    }
    
    
    //Return true si le pseudo est disponible
    func isPseudoDisponible(_ pseudo: String) async throws -> Bool {
        let snapshot = try await userCollection
            .whereField(DBUser.CodingKeys.pseudo.rawValue, isEqualTo: pseudo)
            .getDocuments()

        return snapshot.documents.isEmpty
    }
    
    //Return true si le pseudo existe, false sinon
    func isPseudoInDataBase(_ pseudo: String) async throws -> Bool {
        return try await !isPseudoDisponible(pseudo)
    }
    
    
    // Ajouter deux amis dans leurs listes d'amis respective Firestore
    func addFriendBetween(pseudo1: String, pseudo2: String) async throws {
        let user1 = try await getUserByPseudo(userPseudo: pseudo1)
        let user2 = try await getUserByPseudo(userPseudo: pseudo2)
        
        guard let id1 = user1, let id2 = user2 else { return }

        try await userDocument(userId: id1.userId).updateData([
            DBUser.CodingKeys.amis.rawValue: FieldValue.arrayUnion([id2.pseudo!])
        ])
        
        try await userDocument(userId: id2.userId).updateData([
            DBUser.CodingKeys.amis.rawValue: FieldValue.arrayUnion([id1.pseudo!])
        ])
    }
    
    // Suppression des amis
    func removeFriendBetween(pseudo1: String, pseudo2: String) async throws {
        let user1 = try await getUserByPseudo(userPseudo: pseudo1)
        let user2 = try await getUserByPseudo(userPseudo: pseudo2)

        guard let id1 = user1?.userId, let id2 = user2?.userId else { return }


        try await userDocument(userId: id1).updateData([
            DBUser.CodingKeys.amis.rawValue: FieldValue.arrayRemove([pseudo2])
        ])
        
        try await userDocument(userId: id2).updateData([
            DBUser.CodingKeys.amis.rawValue: FieldValue.arrayRemove([pseudo1])
        ])
    }


}


