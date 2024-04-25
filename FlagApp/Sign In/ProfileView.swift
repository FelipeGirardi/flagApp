import SwiftUI

// MARK: mock ProfileView with pre-set user data

struct ProfileView: View {
    @ObservedObject var signInViewModel: SignInViewModel
    @State private var isProfileEditViewShowing: Bool = false
    // swiftlint:disable object_literal
    let noProfileImage: UIImage = UIImage(named: "NoProfileImage") ?? UIImage()
    private var iapManager: IAPManager

    init(signInViewModel: SignInViewModel, iapManager: IAPManager) {
        self.signInViewModel = signInViewModel
        self.iapManager = iapManager
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("Black2")
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack {
                        Spacer()

                        VStack(spacing: 0) {
                            self.usernameAndConfig
                            ZStack {
                                HStack {
                                    Spacer()
                                    self.flagArea
                                    ForEach(0..<5) { _ in
                                        Spacer()
                                    }
                                }
                                HStack {
                                    self.imageArea
                                }
                            }
                            self.nameArea
                        }

                        VStack(spacing: geometry.size.height / 36) {
                            self.editProfileButton(minWidth: geometry.size.width / 2)

                            self.descriptionArea
                            //followersArea
                            //postsArea

                            Divider()
                                .frame(height: 1)
                                .background(Color("Red1"))
                                .padding(.leading)
                                .padding(.trailing)

                            ChallengeInfoView(userManager: self.signInViewModel.userManager, challengeData: self.signInViewModel.challengeData ?? ChallengeData(), geometry: geometry)
                                .padding(.horizontal, 25)
                                .padding(.top)
                            //treasureArea
                        }

                        ForEach(0..<3) { _ in
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
        }
    }

    private var imageArea: some View {
        // if user has no profile image yet, show NoProfileImage
        Image(uiImage: UIImage(data: self.signInViewModel.profile?.profileImage ?? Data()) ?? self.noProfileImage)
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
    }

    private var flagArea: some View {
        Image(self.signInViewModel.profile?.profileSelectedFlagName ?? "grayFlag")
            .resizable()
            .frame(width: 50, height: 50)
    }

    private var usernameArea: some View {
        // MARK: automatically generate username when user has no username yet
        Text(self.signInViewModel.profile?.nickname ?? "" == "" ? "flagger#01" : self.signInViewModel.profile?.nickname ?? "")
            .font(Font.custom("Heebo-Medium", size: 17))
            .foregroundColor(Color("Gray2"))
            .padding([.leading, .trailing], 25)
            .background(Color("Black1"))
            .cornerRadius(7)
    }

    private var usernameAndConfig: some View {
        ZStack {
            HStack {
                Spacer()
                Button(
                    action: { self.signInViewModel.isLogginOut = true },
                    label: {
                        Image("LogoutButton")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color("Gray2"))
                    }
                )
                .alert(
                    isPresented: self.$signInViewModel.isLogginOut,
                    content: { self.signoutAlert }
                )
            }

            HStack {
                usernameArea
            }
        }
        .padding()
    }

    private var nameArea: some View {
        VStack(spacing: -5) {
            Text(signInViewModel.profile?.name ?? "")
                .font(Font.custom("Heebo-Bold", size: 30))
                .foregroundColor(Color("Red1"))

            Text(signInViewModel.profile?.subtitle ?? "")
                .font(Font.custom("Heebo-Light", size: 15))
                .foregroundColor(Color("Gray2"))
        }
        .padding()
    }

    private func editProfileButton(minWidth: CGFloat) -> some View {
        Button(action: {
            self.isProfileEditViewShowing = true
        }, label: {
            Text(NSLocalizedString("Edit", comment: "Edit"))
                .font(Font.custom("Heebo-Medium", size: 17))
                .foregroundColor(Color("Gray2"))
                .frame(width: UIScreen.main.bounds.width - 50, height: 30)
            NavigationLink(destination: ProfileEditView(signInViewModel: signInViewModel, isProfileEditViewShowing: $isProfileEditViewShowing, usernameText: self.signInViewModel.profile?.nickname ?? "", subtitleText: self.signInViewModel.profile?.subtitle ?? "", aboutMeText: self.signInViewModel.profile?.aboutMe ?? "", profileImage: (UIImage(data: self.signInViewModel.profile?.profileImage ?? Data()) ?? self.noProfileImage), iapManager: iapManager), isActive: self.$isProfileEditViewShowing) {
                EmptyView()
            }
            .isDetailLink(false)
            }
        )
        .background(Color("Black3"))
        .cornerRadius(7)
    }

    private var descriptionArea: some View {
        VStack {
            Text(signInViewModel.profile?.aboutMe ?? "")
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)

            // MARK: Tags area (not in MVP)
//            HStack {
//                Spacer()
//                tagsArea
//            }
        }
        .padding([.top, .bottom])
        .padding([.leading, .trailing], 26)
    }

    private var tagsArea: some View {
        ForEach(signInViewModel.profile?.tags ?? [], id: \.self) { tag in
            self.tagView(tag: tag)
        }
    }

    private func tagView(tag: Profile.Tag?) -> some View {
        Group {
            Text(tag?.title ?? "")
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color.white)
            Spacer()
        }
    }

    private var followersArea: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("1342")
                        .font(Font.custom("Heebo-SemiBold", size: 18))
                        .foregroundColor(Color.white)
                    Text("Followers")
                        .font(Font.custom("Heebo-SemiBold", size: 13))
                        .foregroundColor(Color.white)
                }
                Spacer()
                VStack {
                    Text("2134")
                        .font(Font.custom("Heebo-SemiBold", size: 18))
                        .foregroundColor(Color.white)
                    Text("Following")
                        .font(Font.custom("Heebo-SemiBold", size: 13))
                        .foregroundColor(Color.white)
                }
                Spacer()
            }
            Spacer()
        }
    }

    private var postsArea: some View {
        VStack(spacing: -5) {
            Spacer()
            HStack(spacing: -5) {
                Image("mockPost1")
                    .resizable()
                    .frame(width: 230, height: 230)
                VStack(spacing: -5) {
                    Image("mockPost2")
                        .resizable()
                        .frame(width: 115, height: 115)
                    Image("mockPost3")
                        .resizable()
                        .frame(width: 115, height: 115)
                }
            }
            HStack(spacing: -5) {
                Image("mockPost4")
                    .resizable()
                    .frame(width: 115, height: 115)
                Image("mockPost5")
                    .resizable()
                    .frame(width: 230, height: 115)
            }
            Spacer()
        }
    .padding()
    }

//    private var treasureArea: some View {
//        HStack(spacing: 23) {
//            ForEach(0..<4) { _ in
//                Image("treasure")
//                .resizable()
//                .frame(width: 70, height: 70)
//            }
//        }
//    }

    private var signoutAlert: Alert {
        Alert(
            title: Text(NSLocalizedString("Sign out", comment: "Sign out")),
            message: Text(NSLocalizedString("Sign out description", comment: "You can always access your content by signing back in.")),
            primaryButton: .cancel {
                self.signInViewModel.isLogginOut = false
            },
            secondaryButton: .default(
                Text(NSLocalizedString("Confirm", comment: "Confirm")),
                action: {
                    self.signInViewModel.logout()
                }
            )
        )
    }
}
