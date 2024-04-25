import Combine
import Introspect
import SwiftUI

public struct SearchAndRankingView: View {
    @ObservedObject var viewModel: ViewModel
    private let userManager: UserManager

    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    @State private var tabs = ["Flaggers", "Leaderboard"]

    //swiftlint:disable object_literal
    let noProfileImage: UIImage = UIImage(named: "NoProfileImage") ?? UIImage()

    public init(
        viewModel: ViewModel,
        userManager: UserManager
    ) {
        self.viewModel = viewModel
        self.userManager = userManager
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack {
                flagLogoAndShareView(geometry: geometry)

                /*
                picker
                    .padding()

                if viewModel.selectorIndex == 0 {
                    Group {
                        searchBar
                        userSearchView
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                            }
                    }
                } else {
                    LeaderboardView(viewModel: .init(), userManager: self.userManager, geometry: geometry)
                        .padding(.top)
                }
                 */

                LeaderboardView(viewModel: .init(), userManager: self.userManager, geometry: geometry)
                    .padding(.top)
            }
        }
    }

    private func flagLogoAndShareView(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()

            Image("FlagLogo")
                .resizable()
                .frame(width: 90, height: 35)

            Spacer()

            // MARK: share ranking button action not implemented yet
//            if viewModel.selectorIndex == 1 {
//                Button(action: {
//                    print("Share button clicked")
//                }, label: {
//                    Image("shareButton")
//                        .resizable()
//                        .frame(width: 20, height: 30)
//                        .padding(.trailing, 18)
//                }
//                )
//            }
        }
        .padding(.top)
    }

    private var picker: some View {
        Picker("Numbers", selection: $viewModel.selectorIndex) {
            ForEach(0 ..< tabs.count) { index in
                Text(self.tabs[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var userSearchView: some View {
        if #available(iOS 14.0, *) {
            return AnyView(
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        // Filtered list of profiles, searching from nickname (see searchUsers() )
                        ForEach(self.viewModel.profileArray, id: \.self) { profile in
                            HStack(spacing: 18) {
                                Image(uiImage: UIImage(data: profile.profileImage ?? Data()) ?? self.noProfileImage)
                                    .resizable()
                                    .frame(width: 34, height: 34)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(profile.nickname ?? " ")
                                        .font(Font.custom("Heebo-Medium", size: 15))
                                        .foregroundColor(Color("White1"))
                                    Text(profile.name ?? " ")
                                        .font(Font.custom("Heebo-Light", size: 13))
                                        .foregroundColor(Color("White1"))
                                        .opacity(0.5)
                                }
                            }
                        }
                    }
                }
                .padding()
            )
        } else {
            return AnyView(
                List {
                    // Filtered list of profiles, searching from nickname (see searchUsers() )
                    ForEach(self.viewModel.profileArray, id: \.self) { profile in
                        HStack(spacing: 18) {
                            Image(uiImage: UIImage(data: profile.profileImage ?? Data()) ?? self.noProfileImage)
                                .resizable()
                                .frame(width: 34, height: 34)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(profile.nickname ?? " ")
                                    .font(Font.custom("Heebo-Medium", size: 15))
                                    .foregroundColor(Color("White1"))
                                Text(profile.name ?? " ")
                                    .font(Font.custom("Heebo-Light", size: 13))
                                    .foregroundColor(Color("White1"))
                                    .opacity(0.5)
                            }
                        }
                    }
                }
            )
        }
    }

    var searchBar: some View {
        //swiftlint:disable closure_body_length
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                if #available(iOS 14.0, *) {
                    TextField(
                        "Search",
                        text: $searchText
                    )
                    .onChange(of: searchText) { _ in
                        if searchText.isEmpty {
                            self.viewModel.profileArray = []
                            self.viewModel.idArray = []
                        } else {
                            self.viewModel.searchUsers(searchText: searchText)
                        }
                        self.showCancelButton = true
                    }
                    .foregroundColor(.primary)
                } else {
                    TextField(
                        "Search",
                        text: $searchText,
                        onEditingChanged: { _ in
                            if searchText.isEmpty == false {
                                self.viewModel.searchUsers(searchText: searchText)
                                self.showCancelButton = true
                            } else {
                                self.viewModel.profileArray = []
                                self.viewModel.idArray = []
                            }
                        }
                    )
                    .foregroundColor(.primary)
                }

                Button(action: {
                    self.searchText = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill").opacity(searchText.isEmpty ? 0 : 1)
                }
                )
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)

            if showCancelButton {
                Button("Cancel") {
                    UIApplication.shared.endEditing()
                    self.searchText = ""
                    self.showCancelButton = false
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
        .navigationBarHidden(showCancelButton)
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .first(where: { $0.isKeyWindow })?
            .endEditing(force)
    }
}
