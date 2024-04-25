//
// UserDataRepository.swift
//  FlagApp
//
//  Created by Felipe Girardi on 06/08/20.
//  Copyright © 2020 Flag. All rights reserved.
//
//
// MARK: this file contains functions for loading, creating, updating and deleting user data from Firebase Firestore
//
//import Combine
//import Firebase
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//import Foundation
//import Resolver
//
//class UserDataRepository {
//    @Published var userDataArray = [UserData]()
//}
//
//protocol UserDataProtocol: UserDataRepository {
//    func createUserData(_ userData: UserData)    // called when user is created to initialize user data
//    func updateUserData(_ userData: UserData)    // update user data (ex. after challenge is completed)
//    func deleteUserData(_ userData: UserData)    // delete user data if user deletes account
//}
//
//class FirestoreUserDataRepository: UserDataRepository, UserDataProtocol, ObservableObject {
//    var firestoreDB = Firestore.firestore()
//
//    @Injected var authenticationService: FirebaseAuthService
//    var userDataPath: String = "userData"
//    var userId: String = "unknown"
//    private var cancellables = Set<AnyCancellable>()
//
//    override init() {
//        super.init()
//
//        // assign current user id to userId variable
//        authenticationService.$user
//            .compactMap { user in
//                user?.uid
//            }
//            .assign(to: \.userId, on: self)
//            .store(in: &cancellables)
//
//        // create user data if app is launched for the first time
//        authenticationService.$user
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                self.createUserData(UserData(id: "", totalChallengeScore: 0, userId: ""))
//            }
//            .store(in: &cancellables)
//    }
//
//    // MARK: Load data only once with getDocuments (getSnapshotListener can update data in real time but isn't needed for now)
//    func loadData() {
//        firestoreDB.collection(userDataPath)
//            .whereField("userId", isEqualTo: self.userId)
//            .getDocuments { querySnapshot, error in
//                if let error = error {
//                    print("Error getting documents: \(error)")
//                } else if let querySnapshot = querySnapshot {
//                    self.userDataArray = querySnapshot.documents.compactMap { document -> UserData? in
//                        try? document.data(as: UserData.self)
//                    }
//                    // print for testing
//                    print(self.userDataArray)
//                }
//            }
//    }
//
//    func createUserData(_ userData: UserData) {
//        var userDataWithID = userData
//        let launchedBefore = UserDefaults.standard.bool(forKey: "firstLaunch")
//
//        // Check if app is launched for the first time (and if userId is unknown) to create user data
//        if self.userId != "unknown" && !launchedBefore {
//            userDataWithID.userId = self.userId
//
//            do {
//                _ = try firestoreDB.collection(userDataPath).addDocument(from: userDataWithID)
//                UserDefaults.standard.set(true, forKey: "firstLaunch")
//                //self.loadData() // to print
//            } catch {
//                print("There was an error while trying to create user data \(error.localizedDescription).")
//            }
//        }
//    }
//
//    func updateUserData(_ userData: UserData) {
//        if let userDataID = userData.id {
//            do {
//                try firestoreDB.collection(userDataPath).document(userDataID).setData(from: userData)
//            } catch {
//                print("There was an error while trying to update user data \(error.localizedDescription).")
//            }
//        }
//    }
//
//    func deleteUserData(_ userData: UserData) {
//        if let userDataID = userData.id {
//            firestoreDB.collection(userDataPath).document(userDataID).delete { error in
//                if let error = error {
//                    print("Error removing user data: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
