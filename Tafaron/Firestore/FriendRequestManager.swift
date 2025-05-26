//
//  FriendRequestManager.swift
//  Tafaron
//
//  Created by Yassin Lahbib on 24/05/2025.
//

import Foundation
import FirebaseFirestore

enum FriendRequestStatus: String, Codable {
    case attente
    case accepte
    case refuse
}

struct FriendRequest: Codable {
    
    let friendRequestId: String
    let from: String //pseudo
    let to: String //pseudo
    let status: FriendRequestStatus // "attente", "accepte" ou "refuse"
    let createdAt: Date
    
    
    // Constructeur
    init(friendRequestId: String = UUID().uuidString,
         from: String,
         to: String,
         status: FriendRequestStatus = .attente,
         createdAt: Date = Date()) {
        
        self.friendRequestId = friendRequestId
        self.from = from
        self.to = to
        self.status = status
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case friendRequestId = "friend_request_id"
        case from = "from"
        case to = "to"
        case status = "status"
        case createdAt = "created_at"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.friendRequestId = try container.decode(String.self, forKey: .friendRequestId)
        self.from = try container.decode(String.self, forKey: .from)
        self.to = try container.decode(String.self, forKey: .to)
        self.status = try container.decode(FriendRequestStatus.self, forKey: .status)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.friendRequestId, forKey: .friendRequestId)
        try container.encode(self.from, forKey: .from)
        try container.encode(self.to, forKey: .to)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}


final class FriendRequestManager {
    
    static let shared = FriendRequestManager()
    private init () { }
    
    private let friendRequestCollection = Firestore.firestore().collection("friend_requests")
    
    //Récupérer une référence vers un document friend_requests
    private func friendRequestDocument(friendRequestId: String) -> DocumentReference {
        friendRequestCollection.document(friendRequestId)
    }
    
    
    //Envoyer une demande d'amis
    func sendFriendRequest(from: String, to:String) async throws {
        let request = FriendRequest(from: from, to:to) // Creéation d'un FriendRequest
        
        try friendRequestDocument(friendRequestId: request.friendRequestId).setData(from: request)// Push de la structure sur Firebase
    }
    
    //Écouter les demandes en attente
    // onChange est une fonction qui est appelé automatiquement à chaque fois que les données changent dans Firestore
    func listenForPendingRequests(for pseudo: String, onChange: @escaping ([FriendRequest]) -> Void) -> ListenerRegistration {
        return friendRequestCollection
            .whereField(FriendRequest.CodingKeys.to.rawValue, isEqualTo: pseudo)
            .whereField(FriendRequest.CodingKeys.status.rawValue, isEqualTo: FriendRequestStatus.attente.rawValue)
            .addSnapshotListener { snapshot, error in //.addSnapshotListener permet d'éxécuter la fermeture a chaque fois qu'il y a un changement qui nous interesse dans la collection FriendRequest
                if let error = error {
                    print("Erreur listener demandes amis: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { // Si aucun document (ou snapshot invalide), on envoie un tableau vide
                    onChange([])
                    return
                }
                
                // On décode chaque document Firestore en objet FriendRequest (grâce à Codable)
                // compactMap filtre les erreurs (seuls les documents valides sont ajoutés) les document non valide sont ignorés
                let demandes: [FriendRequest] = documents.compactMap { doc in
                    try? doc.data(as: FriendRequest.self)
                }
                
                onChange(demandes)
            }
    }
    
    
    // Accepter une demande
    func accepterDemande(_ demande: FriendRequest) async throws {
        let docRef = friendRequestDocument(friendRequestId: demande.friendRequestId)
        
        // Met à jour le statut
        try await docRef.updateData([FriendRequest.CodingKeys.status.rawValue: FriendRequestStatus.accepte.rawValue])
        
        // Ajoute les deux comme amis
        try await UserManager.shared.addFriendBetween(pseudo1: demande.from, pseudo2: demande.to)
    }

    // Refuser une demande
    func refuserDemande(_ demande: FriendRequest) async throws {
        let docRef = friendRequestDocument(friendRequestId: demande.friendRequestId)
        
        // Met à jour le statut
        try await docRef.updateData([FriendRequest.CodingKeys.status.rawValue: FriendRequestStatus.refuse.rawValue])
    }

    
    
    
    
    
    
    

    
    
}
