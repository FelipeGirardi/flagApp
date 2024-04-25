import SwiftUI

// swiftlint:disable type_body_length
public struct ChallengeView: View {
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var appNavigationManager: AppNavigationManager
    @State var facePlaceholderScaleChanged = true
    @State var blurBackground = false
    @State var finishedLoading = false

    private let userManager: UserManager
    let isLandscapeActive: Bool

    public init(viewModel: ViewModel, userManager: UserManager, isLandscapeActive: Bool) {
        self.viewModel = viewModel
        self.userManager = userManager
        self.isLandscapeActive = isLandscapeActive
    }

    public var body: some View {
        Group {
            if self.isLandscapeActive {
                if finishedLoading {
                    landscapeMode
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarHidden(true) // landscape does not use navigation bar button
                        .navigationBarBackButtonHidden(true)
                } else {
                    AnyView(ActivityIndicator(isAnimating: .constant(true), style: .large))
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                }
            } else {
                portraitMode
                    .navigationBarTitle("", displayMode: .inline)
                    .navigationBarHidden(false) // portrait uses navigation bar button
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(trailing: self.exitChallengeButton)
            }
        }
        .onDisappear {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        .onAppear {
            if self.isLandscapeActive {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.landscapeRight
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.finishedLoading = true
                }
            }
        }
    }

    private var portraitMode: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    self.faceCameraView
                        .frame(width: geometry.size.width * 0.40, height: geometry.size.height * 0.30)

                    self.youtubePlayerView()
                        .frame(height: geometry.size.height * 0.45)
                        .padding()

                    self.scoreView
                        .frame(width: geometry.size.width * 0.50, height: geometry.size.height * 0.20)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(10)
                        .padding()
                }
                Spacer()
            }
            .background(self.backgroundImageView)
            .onAppear {
                self.viewModel.start()
            }

            if self.viewModel.isExitingChallenge {
                self.exitChallengeAlert
            }

            // MARK: Navigation to End of Challenge (if game is won)
            NavigationLink(
                destination: EndChallengeScreen(scoreObtained: self.viewModel.currentScorePoints, userManager: self.userManager),
                isActive: self.$viewModel.isGameSuccessScreenActive
            ) {
                EmptyView()
            }
            .isDetailLink(false)

            // MARK: Navigation to Failed Challenge (if game is over)
            NavigationLink(
                destination: FailedChallengeView(),
                isActive: self.$viewModel.isGameOverScreenActive
            ) {
                EmptyView()
            }
            .isDetailLink(false)
        }
    }

    private var landscapeMode: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            GeometryReader { geometry in
                HStack {
                    youtubePlayerView()
                        .frame(height: geometry.size.height * 0.94)
                        .padding()

                    VStack(alignment: .center, spacing: 40) {
                        faceCameraView
                            .frame(width: geometry.size.width * 0.20, height: geometry.size.height * 0.40)

                        scoreView
                            .frame(width: geometry.size.width * 0.20, height: geometry.size.height * 0.22)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(10)
                            .padding()
                    }
                }
                Spacer()
            }
            .background(self.backgroundImageView)
            .onAppear {
                self.viewModel.start()
            }

            if self.viewModel.isExitingChallenge {
                exitChallengeAlert
            } else {
                exitChallengeButton
            }

            // MARK: Navigation to End of Challenge (if game is won)
            NavigationLink(
                destination: EndChallengeScreen(scoreObtained: self.viewModel.currentScorePoints, userManager: self.userManager),
                isActive: self.$viewModel.isGameSuccessScreenActive
            ) {
                EmptyView()
            }
            .isDetailLink(false)

            // MARK: Navigation to Failed Challenge (if game is over)
            NavigationLink(
                destination: FailedChallengeView(),
                isActive: self.$viewModel.isGameOverScreenActive
            ) {
                EmptyView()
            }
            .isDetailLink(false)
        }
    }

    private var exitChallengeButton: some View {
       Button(
            action: {
                DispatchQueue.main.async {
                    self.viewModel.isExitingChallenge = true
                    self.blurBackground = true
                }
            }, label: {
                Image("dismissChallenge-icon")
            }
        )
        .frame(width: 40, height: 40)
        .buttonStyle(PlainButtonStyle())
    }

    private var exitChallengeAlert: some View {
        ZStack {
            BlurAlert().edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    Spacer()

                    Text(NSLocalizedString("Exit challenge?", comment: ""))
                        .font(Font.custom("Heebo-Regular", size: 17))
                        .foregroundColor(Color("White1"))

                    Spacer()

                    Text(NSLocalizedString("You will lose all points", comment: ""))
                        .font(Font.custom("Heebo-Light", size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("White1"))
                        .padding([.leading, .trailing])

                    Spacer()
                }
                .frame(width: 300)
                .border(width: 0.5, edges: [.bottom], color: Color(.white).opacity(0.3))

                exitChallengeAlertButtons
            }
            .frame(width: 300, height: 150)
            .background(Color.black)
            .cornerRadius(10)
        }
    }

    private var exitChallengeAlertButtons: some View {
        HStack {
            Button(
                action: {
                    DispatchQueue.main.async {
                        self.viewModel.isExitingChallenge = false
                    }
                }, label: {
                    Text(NSLocalizedString("Cancel", comment: ""))
                        .font(Font.custom("Heebo-Light", size: 18))
                        .foregroundColor(Color(hex: "#FF004E"))
                        .background(Color.clear)
                        .frame(width: 140, height: 50)
                }
            )
            .frame(width: 150, height: 50)
            .border(width: 0.5, edges: [.trailing], color: Color(.white).opacity(0.3))

            Button(
                action: {
                    DispatchQueue.main.async {
                        self.viewModel.isExitingChallenge = false
                        self.viewModel.stop()
                    }
                    self.appNavigationManager.moveToChallengeList = true
                }, label: {
                    Text(NSLocalizedString("Exit", comment: ""))
                        .font(Font.custom("Heebo-Regular", size: 18))
                        .foregroundColor(Color(hex: "#FF004E"))
                        .background(Color.clear)
                        .frame(width: 140, height: 50)
                }
             )
            .frame(width: 150, height: 50)
        }
    }

    private var faceCameraView: some View {
        ZStack {
            CameraView(cameraSessionManager: self.viewModel.session)
                .background(Color.green)
                .cornerRadius(32) // any changes here must be updated in losePointsEffectView too
                .shadow(radius: 5)
            if self.$viewModel.losePointsEffect.wrappedValue == true {
                self.losePointsEffectView
            } else {
                RoundedRectangle(cornerRadius: 24)
                  .foregroundColor(Color.clear)
            }

            self.facePlaceholder
        }
    }

    private var losePointsEffectView: some View {
        RoundedRectangle(cornerRadius: 32)
           .foregroundColor(Color.clear)
           // MARK: Lose point effect: clipShape serve para não deixar a sombra escapar da view
           .overlay(
               RoundedRectangle(cornerRadius: 32)
                   .stroke(Color.red, lineWidth: 5)
                   .shadow(color: Color.red, radius: 20, x: 0, y: 0)
                   .clipShape(
                       RoundedRectangle(cornerRadius: 32)
                   )
                   .shadow(color: Color.red, radius: 10, x: 0, y: 0)
                   .shadow(color: Color.red, radius: 7, x: 0, y: 0)
           )
    }

    private var scoreView: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(NSLocalizedString("Reaction Points", comment: "Reaction Points"))
                .font(Font.custom("Heebo-Medium", size: 18))
                .foregroundColor(Color("White1"))
                .minimumScaleFactor(0.6)
                .padding(.top, 10)
                .padding([.leading, .trailing], 4)

            Text("\(self.viewModel.currentScorePoints)")
                .font(Font.custom("Heebo-SemiBold", size: 54))
                .foregroundColor(Color("White1"))
                .minimumScaleFactor(0.7)
        }
    }

    private func youtubePlayerView() -> some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                YoutubePlayerView(
                    videoID: self.viewModel.challengeInfo.challengeVideoIDs.randomElement() ?? "Vt6hIyZsRBw",
                    isVideoEnded: self.$viewModel.isVideoFinished,
                    videoLengthPercentage: self.$viewModel.videoLengthPercentage,
                    videoLengthInSeconds: self.$viewModel.videoLengthInSeconds,
                    currentVideoTime: self.$viewModel.currentVideoTime
                )
                .disabled(true)

                self.videoTimeSlider(geometry: geometry)
            }
            .cornerRadius(12)
        }
    }

    private func videoTimeSlider(geometry: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .stroke(Color.black, lineWidth: 1)
                .background(Color.black)

            HStack {
                Text(String(format: "%02d:%02d", (Int(viewModel.currentVideoTime.rounded(.toNearestOrEven)) / 60) % 60, Int(viewModel.currentVideoTime.rounded(.toNearestOrEven)) % 60))
                    .font(Font.custom("Heebo-Regular", size: 10))
                    .foregroundColor(Color.white)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray)
                    Rectangle()
                        .foregroundColor(Color("Red1"))
                        .frame(width: (geometry.size.width - 130) * CGFloat(viewModel.videoLengthInSeconds == 0.0 ? 0 : viewModel.currentVideoTime / viewModel.videoLengthInSeconds))
                }
                .frame(width: geometry.size.width - 130, height: 5)
                .animation(.easeInOut(duration: 1))
                .disabled(true)

                Text(String(format: "%02d:%02d", (Int(viewModel.videoLengthInSeconds.rounded(.toNearestOrEven)) / 60) % 60, Int(viewModel.videoLengthInSeconds.rounded(.toNearestOrEven)) % 60))
                    .font(Font.custom("Heebo-Regular", size: 10))
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal)
        }
        .frame(height: 30)
    }

    private var backgroundImageView: some View {
        Image("tntsmile_background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: 10, opaque: true)
            .brightness(-0.2)
            .edgesIgnoringSafeArea(.all)
    }

    private var facePlaceholder: some View {
        Group {
            if self.viewModel.isFaceDetected == false {
                if self.viewModel.enablePulsingPlaceholder {
                    ZStack {
                        Image("face")
                            .scaleEffect(self.facePlaceholderScaleChanged ? 0.7 : 1)
                            .animation(Animation.easeIn(duration: 0.6).repeatForever())
                            .onAppear {
                                DispatchQueue.main.async {
                                    self.facePlaceholderScaleChanged.toggle()
                                }
                            }

                        self.losePointWarnningMessageView
                    }
                } else {
                    Image("face")
                        .onAppear {
                            DispatchQueue.main.async {
                                // Set false to scale start at factor of 1
                                self.facePlaceholderScaleChanged = false
                            }
                        }
                }
            }
        }
    }

    private var losePointWarnningMessageView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("Place your face here!", comment: "Place your face here!"))
                .font(Font.custom("Heebo-Medium", size: 12))
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading:
                    return rect.minX

                case .trailing:
                    return rect.maxX - width
                }
            }
            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing:
                    return rect.minY

                case .bottom:
                    return rect.maxY - width
                }
            }

            // swiftlint:disable identifier_name
            var w: CGFloat {
                switch edge {
                case .top, .bottom:
                    return rect.width

                case .leading, .trailing:
                    return self.width
                }
            }

            // swiftlint:disable identifier_name
            var h: CGFloat {
                switch edge {
                case .top, .bottom:
                    return self.width

                case .leading, .trailing:
                    return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

struct BlurAlert: UIViewRepresentable {
    let style: UIBlurEffect.Style = .dark

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return blur
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
    // swiftlint:disable file_length
}
