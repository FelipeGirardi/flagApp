//
//  SearchAndRankingViewModel.swift
//  FlagApp
//
//  Created by Felipe Girardi on 21/10/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import Combine
import Foundation

public extension SearchAndRankingView {
    final class ViewModel: ObservableObject {
        @Published var idArray: [String] = []
        @Published var profileArray: [Profile] = []
        @Published var selectorIndex = 0

        private let profileAPI: ProfileAPI
        private var cancellables = Set<AnyCancellable>()

        init(profileAPI: ProfileAPI = ProfileAPI()) {
            self.profileAPI = profileAPI
        }

        func searchUsers(searchText: String) {
            // get profiles
            profileAPI.getIdByNickname(searchString: searchText)
                .sink(
                    receiveCompletion: { searchCompletion in
                        switch searchCompletion {
                        case .finished:
                            break

                        case .failure:
                            print("Error searching users")
                        }
                    }, receiveValue: { idArray in
                        self.idArray = idArray
                        var auxArray: [Profile] = []

                        for id in self.idArray {
                            self.profileAPI.loadData(userId: id)
                                .sink(
                                    receiveCompletion: { searchCompletion in
                                        switch searchCompletion {
                                        case .finished:
                                            // modify all array at once at the end of each search to show updated search results
                                            self.profileArray = auxArray

                                        case .failure:
                                            print("Error searching users")
                                        }
                                    }, receiveValue: { profile in
                                        auxArray.append(profile)
                                    }
                                )
                                .store(in: &self.cancellables)
                        }
                    }
                )
                .store(in: &self.cancellables)
        }
    }
}
