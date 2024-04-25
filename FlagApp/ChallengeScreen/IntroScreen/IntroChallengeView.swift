import AVFoundation
import SwiftUI

public struct IntroChallengeView: View {
    @EnvironmentObject var appNavigationManager: AppNavigationManager

    // MARK: Permission Manager Settings
    @EnvironmentObject var permissionManager: PermissionManager

    // MARK: Theme
    @EnvironmentObject var theme: Theme

    @State private var showCam = false
    @State private var recordChallenge = false

    // Landscape mode (switch)
    @State private var isLandscapeModeActive = false

    @State private var showHowToPlay = false
    @State private var showPermissionScreen = false

    // MARK: Navigation Settings
    @State private var dismissView: Bool = false

    private let challengeInfo: ChallengeInfo
    private let userManager: UserManager
    private let cameraManager: CameraSessionManager
    private let detector: Detector
    private var tntChallenge: GenericChallengeProtocol
    private let viewModel: ChallengeView.ViewModel

    public init(
        challengeInfo: ChallengeInfo,
        userManager: UserManager
    ) {
        self.challengeInfo = challengeInfo
        self.userManager = userManager

        self.cameraManager = CameraSessionManager()
        self.detector = Detector(sessionManager: cameraManager, challengeType: challengeInfo.challengeType)

        switch challengeInfo.challengeType {
        case .TNTSmile:
            tntChallenge = TryNotToSmileChallenge(smileDetector: SmileDetector(detector: self.detector))

        case .TNTBlink:
            tntChallenge = TryNotToBlinkChallenge(blinkDetector: BlinkDetector(detector: self.detector))

        case .COMINGSOON:
            fatalError("Coming soon passed as challenge!")
        }

        self.viewModel = ChallengeView.ViewModel(
            session: cameraManager,
            challenge: tntChallenge,
            challengeInfo: challengeInfo
        )

        // MARK: This changes the toggle background color
        UISwitch.appearance().onTintColor = UIColor(rgb: 0xFF094E)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                NavigationView {
                    VStack(alignment: .center) {
                       Spacer(minLength: geometry.size.height * 0.5)

                        self.challengeTitleAndInfo
                            //.padding(.top, 60)

                        Spacer(minLength: geometry.size.height * 0.15)

                        self.landscapeModeSwitch

                        // MARK: Unused for nows
//                        self.showCamSwitch
//                            .padding(.bottom, 50) // uncomment only if the switch from below doesn't exist
    //                    self.recordChallengeSwitch
    //                        .padding(.bottom, 50)

                        self.startChallengeButton(geometry: geometry)

                        Spacer(minLength: geometry.size.height * 0.075)
                    }
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    // MARK: how to play and dismiss buttons are navigation bar items
                    .navigationBarItems(leading: self.howToPlayButton, trailing: self.dismissChallengeButton)
                    .background(
                        Image(self.challengeInfo.challengeBackgroundImageName)
                            .brightness(0.1)
                            .aspectRatio(contentMode: .fit)
                            // MARK: Gradient setup
                            .overlay(
                                LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom)
                            )
                            .edgesIgnoringSafeArea(.all)
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .blur(radius: self.showHowToPlay ? 7 : 0)
                .opacity(self.showHowToPlay ? 0.66 : 1)

                if self.showHowToPlay {
                    self.howToPlayPopup(geometry: geometry)
                        .padding(.top, geometry.size.height * 0.06)
                }

                if self.showPermissionScreen && !self.permissionManager.isCameraAutorized {
                    PermissionChallengeScreen(showingPermissionView: self.$showPermissionScreen)
                }
            }
        }
    }

    private var topButtons: some View {
        HStack {
            self.howToPlayButton
            Spacer()
            self.dismissChallengeButton
        }
        .padding([.leading, .trailing], 18)
        .onAppear {
            self.theme.tabviewHidden = true
        }
    }

    private var howToPlayButton: some View {
        Button(
            action: {
                self.showHowToPlay = true
            },
            label: { Text(NSLocalizedString("HOW TO PLAY", comment: "HOW TO PLAY"))
                .font(Font.custom("Heebo-Medium", size: 13))
               .foregroundColor(Color.white)
               .padding(10)
            }
        )
        .frame(height: 30)
        .background(Color.black.opacity(0.5))
        .cornerRadius(40)
        .padding(.top, 30)
        .buttonStyle(PlainButtonStyle())
        .disabled(self.showHowToPlay)
    }

    func howToPlayPopup(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack {
                titleAndDescription

                descriptionDetails

                Group {
                    ForEach(0..<3) { _ in
                        Spacer()
                    }

                    self.dismissHowToPlayButton

                    Spacer()
                    Spacer()
                }
            }
            .padding([.leading, .trailing], geometry.size.width * 0.065)
        }
        .frame(minWidth: geometry.size.width * 0.913, maxWidth: geometry.size.width * 0.913, minHeight: geometry.size.height * 0.8, maxHeight: geometry.size.height * 0.95)
        .background(Blur())
        .cornerRadius(14)
        .animation(.easeIn)
    }

    private var titleAndDescription: some View {
        Group {
            Spacer()

            HStack {
                Button(
                    action: {
                        self.showHowToPlay = false
                    }, label: {
                        Text(NSLocalizedString("Close", comment: "Close"))
                            .font(Font.custom("Heebo-Regular", size: 18))
                            .minimumScaleFactor(0.75)
                            .foregroundColor(Color("Red1"))
                    }
                )
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }

            Spacer()

            Text(NSLocalizedString("HOW TO PLAY", comment: "HOW TO PLAY"))
                .font(Font.custom("Heebo-Medium", size: 26))
                .foregroundColor(Color.white)

            Spacer()

            Text(self.challengeInfo.challengeHowToPlayDescription)
                .font(Font.custom("Heebo-Light", size: 18))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.75)
        }
    }

    private var dismissHowToPlayButton: some View {
        Button(
            action: {
                self.showHowToPlay = false
            }, label: {
                Text(NSLocalizedString("GOT IT!", comment: "GOT IT!"))
                    .frame(width: 200, height: 30)
                    .font(Font.custom("Heebo-Regular", size: 18))
                    .foregroundColor(Color.white)
            }
        )
        .frame(width: 220, height: 40)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color(hex: "FF004E"), lineWidth: 1)
        )
    }

    private var descriptionDetails: some View {
        Group {
            Spacer()
            Spacer()

            Image("reactionPointsHowToPlay-icon")

            Text(NSLocalizedString("If you reach 0 RP", comment: "If you reach 0 RP, you failed the challenge!"))
                .font(Font.custom("Heebo-Light", size: 18))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.75)

            Spacer()
            Spacer()

            Image("rankHowToPlay-icon")

        Text(NSLocalizedString("The higher your RP", comment: "The higher your RP, the better your ranking."))
            .font(Font.custom("Heebo-Light", size: 18))
            .foregroundColor(Color.white)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.75)
        }
    }

    private var dismissChallengeButton: some View {
        Button(
            action: {
                self.appNavigationManager.moveToChallengeList = true
            }, label: {
                Image("dismissChallenge-icon")
            }
        )
        .frame(width: 40, height: 40)
        .padding(.top, 30)
        .buttonStyle(PlainButtonStyle())
        .disabled(self.showHowToPlay)
    }

    private var challengeTitleAndInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(self.challengeInfo.challengeName)
                .font(Font.custom("Heebo-Bold", size: 34))
                .foregroundColor(Color("White1"))

            Text(self.challengeInfo.challengeFullDescription)
                .font(Font.custom("Heebo-Light", size: 15))
                .foregroundColor(Color("White1"))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding([.leading, .trailing], 18)
    }

    private var landscapeModeSwitch: some View {
        HStack {
            if #available(iOS 14.0, *) {
                Toggle(isOn: $isLandscapeModeActive) {
                    Text(NSLocalizedString("Landscape mode", comment: ""))
                        .font(Font.custom("Heebo-Regular", size: 18))
                        .foregroundColor(Color("White1"))
                }
                .padding([.leading, .trailing], 18)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#FF094E")))
            } else {
                Toggle(isOn: $isLandscapeModeActive) {
                    Text(NSLocalizedString("Landscape mode", comment: ""))
                        .font(Font.custom("Heebo-Regular", size: 18))
                        .foregroundColor(Color("White1"))
                }
                .padding([.leading, .trailing], 18)
            }
        }
        .frame(height: 50)
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding([.leading, .trailing], 18)
        .padding(.bottom, 20)
    }

    // Unused for now
//    private var showCamSwitch: some View {
//        HStack {
//            Toggle(isOn: $showCam) {
//                Text(NSLocalizedString("Show your face cam", comment: "Show your face cam"))
//                    .font(Font.custom("Heebo-Regular", size: 18))
//                    .foregroundColor(Color("White1"))
//            }
//            .frame(height: 50)
//        }
//        .frame(width: 380, height: 50)
//        .background(Color.black.opacity(0.5))
//        .cornerRadius(10)
//    }
//
//    private var recordChallengeSwitch: some View {
//        HStack {
//            Toggle(isOn: $recordChallenge) {
//                Text(NSLocalizedString("Record your challenge", comment: "Record your challenge"))
//                    .font(Font.custom("Heebo-Regular", size: 18))
//                    .foregroundColor(Color("White1"))
//            }
//            .frame(height: 50)
//        }
//        .frame(width: 380, height: 50)
//        .background(Color.black.opacity(0.5))
//        .cornerRadius(10)
//    }

    func startChallengeButton(geometry: GeometryProxy) -> some View {
            Button(
                action: {
                    // MARK: Permission Management - Need to check app internal authorization status value
                    if self.permissionManager.cameraPermissionStatus() == .denied ||
                        self.permissionManager.cameraPermissionStatus() == .notDetermined {
                        self.showPermissionScreen = true
                    } else if self.permissionManager.cameraPermissionStatus() == .authorized {
                        self.showPermissionScreen = false
                        self.permissionManager.isCameraAutorized = true
                        self.dismissView = true
                    }
                }, label: {
                    Text(NSLocalizedString("START", comment: "START"))
                        .font(Font.custom("Heebo-SemiBold", size: 21))
                        .foregroundColor(Color("White1"))
                        .frame(width: geometry.size.width - 36, height: geometry.size.height * 0.075)
                        .background(Color(hex: "FF004E"))
                        .cornerRadius(30)

                    NavigationLink(
                        destination: ChallengeView(viewModel: self.viewModel, userManager: self.userManager, isLandscapeActive: isLandscapeModeActive),
                        isActive: self.$dismissView
                    ) {
                        EmptyView()
                    }
                    .isDetailLink(false)
                }
            )
            .disabled(self.showHowToPlay)
            .padding()
    }
}
