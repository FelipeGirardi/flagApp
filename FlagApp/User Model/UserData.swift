//
//  UserData.swift
//  FlagApp
//
//  Created by Felipe Girardi on 06/08/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct UserData: Codable, Identifiable {
    @DocumentID var id: String?
    var totalChallengeScore: Int
    var userId: String?
}
