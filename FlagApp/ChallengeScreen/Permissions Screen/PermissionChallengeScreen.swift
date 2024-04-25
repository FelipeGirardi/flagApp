import AVFoundation
import SwiftUI

struct PermissionChallengeScreen: View {
    @EnvironmentObject var permissionManager: PermissionManager

    @Binding var showingPermissionView: Bool
    @State private var showCheckmark: Bool = false
    @State private var color = Color(hex: "#FF004E")

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    self.dismissScreenButton
                }

                Spacer(minLength: geometry.size.height * 0.18)

                self.middleLabels

                Spacer(minLength: geometry.size.height * 0.15)

                ZStack(alignment: .leading) {
                    self.allowCameraPermissionButton(geometry: geometry)

                    if self.showCheckmark {
                        self.checkMarkLabel
                    }
                }

                Spacer(minLength: geometry.size.height * 0.3)
            }
            .padding([.leading, .trailing], geometry.size.width * 0.077)
            .background(Blur())
            .edgesIgnoringSafeArea(.all)
        }
    }

    private var dismissScreenButton: some View {
        Button(
            action: {
                self.showingPermissionView = false
            }, label: {
                Image("dismissChallenge-icon")
                    .frame(width: 40, height: 40)
                    .padding(.top, 64)
            }
        )
        .buttonStyle(PlainButtonStyle())
    }

    private var middleLabels: some View {
        VStack(alignment: .center, spacing: 36) {
            Text(NSLocalizedString("Challenge Permissions", comment: "Challenge Permissions"))
                .font(Font.custom("Heebo-Bold", size: 34))
                .foregroundColor(Color("White1"))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.9)

            Text(NSLocalizedString("Permissions description", comment: "To enjoy the full experience..."))
                .font(Font.custom("Heebo-Light", size: 15))
                .foregroundColor(Color("White1"))
                .multilineTextAlignment(.center) // ajusts each line of text to be in the center
        }
    }

    func allowCameraPermissionButton(geometry: GeometryProxy) -> some View {
        Button(action: {
                if self.permissionManager.cameraPermissionStatus() == .denied {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) // open settings for camera permission
                } else {
                    self.permissionManager.activateCameraPermissionRequest { result -> Void in
                        if result { // paint the label green if permission is authorized
                            withAnimation(.easeInOut(duration: 0.75)) {
                                    self.showCheckmark = true
                                    self.color = Color(hex: "#32D74B")
                            }
                        }
                    }
                }
            }, label: {
                Text(NSLocalizedString("Allow camera access", comment: "Allow camera access"))
                    .font(Font.custom("Heebo-Regular", size: 18))
                    .foregroundColor(Color.white)
                    .colorMultiply(self.color)
                    .frame(width: geometry.size.width - 64, height: 50)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
            }
        )
        .buttonStyle(PlainButtonStyle())
    }

    private var checkMarkLabel: some View {
        HStack {
            Image("green-checkmark-permission")
                .frame(width: 30, height: 26)
                .foregroundColor(Color(hex: "#32D74B"))
                .padding(.leading, 15)
            Spacer()
        }
    }
}
