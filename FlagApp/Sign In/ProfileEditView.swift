//
//  ProfileEditView.swift
//  FlagApp
//
//  Created by Felipe Girardi on 02/09/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var signInViewModel: SignInViewModel
    @State var showFlagStoreSheet: Bool = false
    private var iapManager: IAPManager

    let usernameCharacterLimit = 20
    @State var usernameText: String

    let subtitleCharacterLimit = 30
    @State var subtitleText: String

    let aboutMeCharacterLimit = 140
    @State var aboutMeText: String

    @State var aboutMeTextViewHeight: CGFloat = 37
    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = 37
        let maxHeight: CGFloat = 200

        if aboutMeTextViewHeight < minHeight {
            return minHeight
        }

        if aboutMeTextViewHeight > maxHeight {
            return maxHeight
        }

        return aboutMeTextViewHeight
    }

    @Binding var isProfileEditViewShowing: Bool
    @State var showImagePicker: Bool = false
    @State var showImageActionSheet: Bool = false
    @State var showCamera: Bool = false
    @State var mustRemoveImage: Bool = false
    @State var profileImage: UIImage
    // swiftlint:disable object_literal
    let noProfileImage: UIImage = UIImage(named: "NoProfileImage") ?? UIImage()

    init(signInViewModel: SignInViewModel, isProfileEditViewShowing: Binding<Bool>, usernameText: String, subtitleText: String, aboutMeText: String, profileImage: UIImage, iapManager: IAPManager) {
        self.signInViewModel = signInViewModel
        self.iapManager = iapManager
        self._isProfileEditViewShowing = isProfileEditViewShowing
        self._profileImage = State(wrappedValue: profileImage)
        self._usernameText = State(wrappedValue: usernameText)
        self._subtitleText = State(wrappedValue: subtitleText)
        self._aboutMeText = State(wrappedValue: aboutMeText)
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("Black2")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    self.navigationButtons(geometry: geometry)

                    ScrollView {
                        VStack(spacing: 21) {
                            VStack(spacing: 13) {
                                self.usernameAndImageArea(geometry: geometry)

                                VStack(spacing: 10) {
                                    self.nameArea
                                    self.subtitleTextField(geometry: geometry)
                                }
                            }
                            .padding(.top)

                            VStack(alignment: .leading, spacing: 15) {
                                self.aboutMeArea(geometry: geometry)
                                //self.tagsArea (not in MVP)
                                self.challengeInfoArea(geometry: geometry)
                            }
                            .padding([.leading, .trailing], 18)

                            ForEach(0..<3) { _ in
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .sheet(isPresented: self.$showImagePicker) {
                ImagePickerView(sourceType: .photoLibrary) { pickedImage in
                    self.profileImage = pickedImage
                }
            }
            // MARK: Camera picker view in sheet for now, should be NavigationLink (must remove tab bar first)
            .popover(isPresented: self.$showCamera) {
                ImagePickerView(sourceType: .camera) { pickedImage in
                    self.profileImage = pickedImage
                }
            }
            .sheet(
                isPresented: self.$showFlagStoreSheet,
                onDismiss: {
                    print("Update selected flag view")
                }, content: {
                    FlagStoreView(viewModel: FlagStoreViewModel(userManager: self.signInViewModel.userManager, iapManager: self.iapManager))
                }
            )
        }
    }

    func usernameAndImageArea(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            self.usernameTextField(geometry: geometry)

            imageAndFlagArea
        }
    }

    private var imageAndFlagArea: some View {
        ZStack {
            HStack {
                Spacer()
                self.flagArea
                ForEach(0..<6) { _ in
                    Spacer()
                }
            }

            HStack {
                ZStack(alignment: .bottomTrailing) {
                    self.imageArea
                    Image("SelectPicture")
                }
                .onTapGesture {
                    self.showImageActionSheet = true
                }
                .actionSheet(isPresented: self.$showImageActionSheet) {
                    self.actionSheetArea
                }
            }
        }
    }

    private var flagArea: some View {
        VStack {
            Image(self.signInViewModel.profile?.profileSelectedFlagName ?? "grayFlag")
                .resizable()
                .frame(width: 50, height: 50)
                .padding(10)
                .overlay(
                    Circle()
                        .stroke(Color("Red1"), lineWidth: 1)
                )

            Text(NSLocalizedString("Change flag", comment: "Change flag"))
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color("Red1"))
                .multilineTextAlignment(.center)
        }
        .onTapGesture {
            self.showFlagStoreSheet = true
        }
    }

    func navigationButtons(geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            HStack {
                self.backToProfileButton
                Spacer()
                self.doneEditingButton
            }
            .frame(alignment: .center)
            .padding([.leading, .trailing], 10)

            Divider()
                .background(Color("Gray4"))
        }
        .padding(.top)
    }

    func usernameTextField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(NSLocalizedString("Your username must have 3 characters or more!", comment: "Your username must have 3 characters or more!"))
                .font(Font.custom("Heebo-Regular", size: 12))
                .foregroundColor(Color("Red1"))
                .opacity(self.usernameText.count < 3 ? 1 : 0)

            HStack(spacing: 10) {
                Image("Pencil")

                TextField("", text: self.$usernameText)
                    .font(Font.custom("Heebo-Regular", size: 16))
                    .foregroundColor(Color.white)
                    .onReceive(self.usernameText.publisher.collect()) {
                        self.usernameText = String($0.prefix(self.usernameCharacterLimit))
                    }
            }
            .frame(width: geometry.size.width * 0.5, height: 35)
            .padding([.leading, .trailing])
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Gray4"), lineWidth: 1)
            )
        }
    }

    func subtitleTextField(geometry: GeometryProxy) -> some View {
        HStack(spacing: 10) {
            Image("Pencil")

            ZStack(alignment: .leading) {
                if self.subtitleText.isEmpty {
                    Text(NSLocalizedString("Subtitle here", comment: "Subtitle here"))
                        .font(Font.custom("Heebo-Regular", size: 14))
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.leading, 4)
                }

                TextField("", text: self.$subtitleText)
                    .font(Font.custom("Heebo-Regular", size: 16))
                    .foregroundColor(Color.white)
                    .onReceive(self.subtitleText.publisher.collect()) {
                        self.subtitleText = String($0.prefix(self.subtitleCharacterLimit))
                    }
            }
        }
        .frame(width: geometry.size.width * 0.6, height: 35)
        .padding([.leading, .trailing])
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("Gray4"), lineWidth: 1)
        )
    }

    var imageArea: some View {
        Image(uiImage: profileImage)
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
    }

    // to do: avoid repeated code
    var actionSheetArea: ActionSheet {
        ActionSheet(
            title:
                Text(NSLocalizedString("Change profile picture", comment: "Change profile picture"))
                    .font(Font.custom("Heebo-Regular", size: 14)),
            buttons: self.profileImage != self.noProfileImage ? [
                .default(
                    Text(NSLocalizedString("Choose in library", comment: "Choose in library"))
                        .font(Font.custom("Heebo-Light", size: 20))) {
                            self.showImagePicker = true
                        },
                .default(
                    Text(NSLocalizedString("Take photo", comment: "Take photo"))
                        .font(Font.custom("Heebo-Light", size: 20))) {
                            self.showCamera = true
                        },
                .destructive(
                    Text(NSLocalizedString("Remove profile picture", comment: "Remove profile picture"))
                        .font(Font.custom("Heebo-Light", size: 20))
                        .foregroundColor(Color("Red1"))) {
                            self.mustRemoveImage = true
                            self.profileImage = self.noProfileImage
                        },
                .cancel(
                    Text(NSLocalizedString("Cancel", comment: "Cancel"))
                        .font(Font.custom("Heebo-Regular", size: 20)))
            ] : [
                .default(
                    Text(NSLocalizedString("Choose in library", comment: "Choose in library"))
                        .font(Font.custom("Heebo-Light", size: 20))) {
                            self.showImagePicker = true
                        },
                .default(
                    Text(NSLocalizedString("Take photo", comment: "Take photo"))
                        .font(Font.custom("Heebo-Light", size: 20))) {
                            self.showCamera = true
                        },
                .cancel(
                    Text(NSLocalizedString("Cancel", comment: "Cancel"))
                        .font(Font.custom("Heebo-Regular", size: 20)))
            ]
        )
    }

    var nameArea: some View {
        Text(signInViewModel.profile?.name ?? "")
            .font(Font.custom("Heebo-Bold", size: 30))
            .foregroundColor(Color("Red1"))
    }

    func aboutMeArea(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("About me", comment: "About me"))
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color("Red1"))

            ZStack(alignment: .topLeading) {
                if self.aboutMeText.isEmpty {
                    Text(NSLocalizedString("Write something that defines you!", comment: "Write something that defines you!"))
                        .font(Font.custom("Heebo-Regular", size: 14))
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.leading, 16)
                        .padding(.top, 8)
                }

                if #available(iOS 14.0, *) {
                    TextEditor(text: self.$aboutMeText)
                        .foregroundColor(Color.white)
                        .background(Color.clear)
                        .frame(minHeight: 66, maxHeight: 200)
                        .padding([.leading, .trailing], 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Gray4"), lineWidth: 1)
                        )
                        .onReceive(self.aboutMeText.publisher.collect()) {
                            self.aboutMeText = String($0.prefix(self.aboutMeCharacterLimit))
                        }
                } else {
                    CustomTextView(text: self.$aboutMeText, height: self.$aboutMeTextViewHeight)
                        .frame(height: self.aboutMeTextViewHeight, alignment: .center)
                        .padding([.leading, .trailing], 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Gray4"), lineWidth: 1)
                        )
                        .onReceive(self.aboutMeText.publisher.collect()) {
                            self.aboutMeText = String($0.prefix(self.aboutMeCharacterLimit))
                        }
                }
            }
        }
    }

    var tagsArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tags")
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color("Red1"))

            HStack(spacing: 7) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 25) {
                        Text("+")
                            .font(Font.custom("Heebo-Regular", size: 20))
                            .foregroundColor(Color("Gray4"))
                        Text("Add")
                            .font(Font.custom("Heebo-Regular", size: 14))
                            .foregroundColor(Color("Gray4"))
                        Spacer()
                    }
                    .padding(.leading, 11)
                    .frame(width: 116, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("Gray4"), lineWidth: 1)
                    )
                }
            }
            .padding(9)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("Gray4"), lineWidth: 1)
            )
        }
    }

    func challengeInfoArea(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NSLocalizedString("Level", comment: "Level"))
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color("Red1"))

            ChallengeInfoView(userManager: self.signInViewModel.userManager, challengeData: signInViewModel.challengeData ?? ChallengeData(), geometry: geometry)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Gray4"), lineWidth: 1)
                )
        }
    }

    var backToProfileButton: some View {
        Button(action: {
            self.isProfileEditViewShowing = false
        }, label: {
            HStack(spacing: 7) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: 13, height: 22)
                    .foregroundColor(Color("Red1"))

                Text(NSLocalizedString("Profile", comment: "Profile"))
                    .font(Font.custom("Heebo-Regular", size: 18))
                    .foregroundColor(Color("Red1"))
            }
        }
        )
    }

    var doneEditingButton: some View {
        Button(action: {
            // MARK: Save to Firebase
            var profileImageData: Data = Data()
            if self.profileImage != self.noProfileImage {
                profileImageData = self.profileImage.jpegData(compressionQuality: 0.5) ?? Data()
            }

            let newProfileData: Profile = Profile(id: self.signInViewModel.profile?.id, userId: self.signInViewModel.profile?.userId, name: self.signInViewModel.profile?.name, nickname: self.usernameText, subtitle: self.subtitleText, aboutMe: self.aboutMeText, cash: self.signInViewModel.profile?.cash, boughtFlagsIDs: self.signInViewModel.profile?.boughtFlagsIDs, tags: [], profileImage: profileImageData, profileSelectedFlagName: self.signInViewModel.profile?.profileSelectedFlagName)
            self.signInViewModel.updateProfile(newProfileData: newProfileData, mustRemoveImage: self.mustRemoveImage)

            self.isProfileEditViewShowing = false
        }, label: {
            Text(NSLocalizedString("Done", comment: "Done"))
                .font(Font.custom("Heebo-Bold", size: 18))
                .foregroundColor(self.usernameText.count < 3 ? Color(UIColor.placeholderText) : Color("Red1"))
        }
        )
            .disabled(self.usernameText.count < 3)
    }
}

// MARK: extension to dismiss keyboard when tapping screen
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
