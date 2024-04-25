import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

public class ProfileAPI {
    var firestoreDB = Firestore.firestore()
    var profileDataPath: String = "profile"
    var challengeDataPath: String = "challengeData"
    var storageRef = Storage.storage().reference()

    public init() { }

    func createProfile(userId: String, name: String? = nil) -> AnyPublisher<Profile, ProfileError> {
        Deferred {
            Future { completion in
                // add new profile and its challenge data (both with the same userId)
                let newProfile: Profile = Profile(userId: userId, name: name, nickname: "flagger#01", subtitle: "", aboutMe: "", cash: 0, boughtFlagsIDs: [], tags: [])
                let newChallengeData: ChallengeData = ChallengeData(userId: userId, totalPoints: 0, level: 1, numberOfAchievements: 0)
                do {
                    //_ = try self.firestoreDB.collection(self.profileDataPath).document(userId).setData(from: newProfile)
                    _ = try self.firestoreDB.collection(self.profileDataPath).addDocument(from: newProfile)
                    _ = try self.firestoreDB.collection(self.challengeDataPath).addDocument(from: newChallengeData)
                    completion(.success(newProfile))
                } catch {
                    completion(.failure(.unknown))
                }
            }
        }.eraseToAnyPublisher()
    }

    func loadData(userId: String) -> AnyPublisher<Profile, ProfileAPI.Error> {
        Deferred {
            Future { [weak self] completion in
                guard let self = self
                    else {
                        return
                    }

                self.firestoreDB.collection(self.profileDataPath)
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments { querySnapshot, error in
                        guard error == nil
                            else {
                                completion(.failure(.unknown))
                                return
                            }
                        if let document = querySnapshot!.documents.first {
                            // Usuário já existe
                            if var profile = try? document.data(as: Profile.self) {
                                // download profile image
                                let imgPathString = "users/" + userId + "/" + "profileImg.jpg"
                                let profileImgRef = self.storageRef.child(imgPathString)

                                profileImgRef.getData(maxSize: 1 * 1_024 * 1_024) { data, error in
                                    if error != nil {
                                        print("Image not found: user has no profile image yet")
                                    } else {
                                        profile.profileImage = data
                                    }
                                    completion(.success(profile))
                                }
                            }
                        } else {
                            completion(.failure(.profileNotFound))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }

    func getNicknames(searchString: String) -> AnyPublisher<[String], ProfileAPI.Error> {
        Deferred {
            Future { [weak self] completion in
                guard let self = self
                    else {
                        return
                    }

                self.firestoreDB.collection(self.profileDataPath)
                    .whereField("nickname", isGreaterThanOrEqualTo: searchString)
                    .whereField("nickname", isLessThanOrEqualTo: searchString + "~")
                    .getDocuments { querySnapshot, error in
                        guard error == nil else {
                            completion(.failure(.unknown))
                            return
                        }
                        var nicknamesArray: [String] = []
                        for document in querySnapshot!.documents {
                            guard let nickname: String = document.data()["nickname"] as? String else {
                                completion(.failure(.unknown))
                                return
                            }
                            nicknamesArray.append(nickname)
                        }
                        completion(.success(nicknamesArray))
                    }
            }
        }
        .eraseToAnyPublisher()
    }

    // Get name that belongs to user nickname on search
    func getNames(searchString: String) -> AnyPublisher<[String], ProfileAPI.Error> {
        Deferred {
            Future { [weak self] completion in
                guard let self = self
                    else {
                        return
                    }

                self.firestoreDB.collection(self.profileDataPath)
                    .whereField("nickname", isGreaterThanOrEqualTo: searchString)
                    .whereField("nickname", isLessThanOrEqualTo: searchString + "~")
                    .getDocuments { querySnapshot, error in
                        guard error == nil else {
                            completion(.failure(.unknown))
                            return
                        }
                        var namesArray: [String] = []
                        for document in querySnapshot!.documents {
                            guard let name: String = document.data()["name"] as? String else {
                                completion(.failure(.unknown))
                                return
                            }
                            namesArray.append(name)
                        }
                        completion(.success(namesArray))
                    }
            }
        }
        .eraseToAnyPublisher()
    }

    // fazer funcao para imagem
    func getIdByNickname(searchString: String) -> AnyPublisher<[String], ProfileAPI.Error> {
        Deferred {
            Future { [weak self] completion in
                guard let self = self
                    else {
                        return
                    }

                self.firestoreDB.collection(self.profileDataPath)
                    .whereField("nickname", isGreaterThanOrEqualTo: searchString)
                    .whereField("nickname", isLessThanOrEqualTo: searchString + "~")
                    .getDocuments { querySnapshot, error in
                        guard error == nil else {
                            completion(.failure(.unknown))
                            return
                        }
                        var userIdArray: [String] = []
                        for document in querySnapshot!.documents {
                            guard let id: String = document.data()["userId"] as? String else {
                                completion(.failure(.unknown))
                                return
                            }
                            userIdArray.append(id)
                        }
                        completion(.success(userIdArray))
                    }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveProfileData(userId: String, newProfileData: Profile, mustRemoveImage: Bool) -> AnyPublisher<Profile, ProfileAPI.Error> {
        Deferred {
            Future { [weak self] completion in
                guard let self = self
                    else {
                        return
                    }

                if mustRemoveImage {
                    self.deleteProfileImage(userId: userId)
                } else {
                    self.saveProfileImage(userId: userId, newProfileData: newProfileData)
                }

                // save profile info to Firestore
                self.firestoreDB.collection(self.profileDataPath)
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments { querySnapshot, error in
                        guard error == nil
                            else {
                                completion(.failure(.unknown))
                                return
                            }
                        if let document = querySnapshot!.documents.first {
                            document.reference.updateData(
                                [
                                "aboutMe": newProfileData.aboutMe ?? "",
                                "nickname": newProfileData.nickname ?? "",
                                "subtitle": newProfileData.subtitle ?? "",
                                "tags": newProfileData.tags
                                ]
                            ) { err in
                                if err != nil {
                                    completion(.failure(.unknown))
                                } else {
                                    completion(.success(newProfileData))
                                }
                            }
                        } else {
                            completion(.failure(.profileNotFound))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveProfileImage(userId: String, newProfileData: Profile) {
        // save image to Firebase Storage
        let profileImgData = newProfileData.profileImage ?? Data()
        if profileImgData != Data() {
            let imgPathString = "users/" + userId + "/" + "profileImg.jpg"
            let profileImgRef = self.storageRef.child(imgPathString)

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"

            profileImgRef.putData(profileImgData, metadata: metadata) { _, error in
                if error == nil {
                    print("Image uploaded successfully")
                } else {
                    print("Error uploading image: \(String(describing: error))")
                }
            }
        }
    }

    func deleteProfileImage(userId: String) {
        // delete image from Firebase Storage
        let imgPathString = "users/" + userId + "/" + "profileImg.jpg"
        let profileImgRef = self.storageRef.child(imgPathString)

        profileImgRef.delete { error in
            if let error = error {
                print("Error deleting image: \(String(describing: error))")
            } else {
                print("Image deleted successfully")
            }
        }
    }

    func getCash(userID: String) -> AnyPublisher<Int, ProfileAPI.Error> {
        Future { [weak self] completion in
            guard let self = self
                else {
                    return
                }
            self.firestoreDB.collection(self.profileDataPath)
                .whereField("userId", isEqualTo: userID)
                .getDocuments { querySnapshot, error in
                    guard error == nil
                        else {
                            completion(.failure(.unknown))
                            return
                        }
                    if let document = querySnapshot!.documents.first {
                        if let profile = try? document.data(as: Profile.self) {
                            let currentCash = profile.cash ?? 0
                            completion(.success(currentCash))
                        }
                    } else {
                        completion(.failure(.profileNotFound))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func saveCash(userID: String, newTotalCash: Int) -> AnyPublisher<Void, ProfileAPI.Error> {
        Future { [weak self] completion in
            guard let self = self
                else {
                    return
                }
            self.firestoreDB.collection(self.profileDataPath)
                .whereField("userId", isEqualTo: userID)
                .getDocuments { querySnapshot, error in
                    guard error == nil
                        else {
                            completion(.failure(.unknown))
                            return
                        }
                    if let document = querySnapshot!.documents.first {
                        document.reference.updateData(["cash": newTotalCash]) { err in
                            if err != nil {
                                completion(.failure(.unknown))
                            } else {
                                completion(.success(Void()))
                            }
                        }
                    } else {
                        completion(.failure(.profileNotFound))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func saveBoughtFlagsIDsArray(userID: String, newBoughtFlagsIDsArray: [String], selectedFlagName: String) -> AnyPublisher<Void, ProfileAPI.Error> {
        Future { [weak self] completion in
            guard let self = self
                else {
                    return
                }
            self.firestoreDB.collection(self.profileDataPath)
                .whereField("userId", isEqualTo: userID)
                .getDocuments { querySnapshot, error in
                    guard error == nil
                        else {
                            completion(.failure(.unknown))
                            return
                        }
                    if let document = querySnapshot!.documents.first {
                        document.reference.updateData(
                            [
                                "boughtFlagsIDs": newBoughtFlagsIDsArray,
                                "profileSelectedFlagName": selectedFlagName
                            ]
                        ) { err in
                            if err != nil {
                                completion(.failure(.unknown))
                            } else {
                                completion(.success(Void()))
                            }
                        }
                    } else {
                        completion(.failure(.profileNotFound))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func saveSelectedFlag(userID: String, selectedFlagName: String) -> AnyPublisher<Void, ProfileAPI.Error> {
        Future { [weak self] completion in
            guard let self = self
                else {
                    return
                }
            self.firestoreDB.collection(self.profileDataPath)
                .whereField("userId", isEqualTo: userID)
                .getDocuments { querySnapshot, error in
                    guard error == nil
                        else {
                            completion(.failure(.unknown))
                            return
                        }
                    if let document = querySnapshot!.documents.first {
                        document.reference.updateData(
                            ["profileSelectedFlagName": selectedFlagName]
                        ) { err in
                            if err != nil {
                                completion(.failure(.unknown))
                            } else {
                                completion(.success(Void()))
                            }
                        }
                    } else {
                        completion(.failure(.profileNotFound))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}

extension ProfileAPI {
    enum Error: Swift.Error {
        case profileNotFound
        case unknown
    }
}
