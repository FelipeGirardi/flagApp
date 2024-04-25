import SwiftUI

struct MainSignInView: View {
    @ObservedObject var signInViewModel: SignInViewModel
    private var iapManager: IAPManager

    init(signInViewModel: SignInViewModel, iapManager: IAPManager) {
        self.signInViewModel = signInViewModel
        self.iapManager = iapManager
    }

    var body: some View {
        if signInViewModel.profile == nil {
            if signInViewModel.doingSignIn {
                return AnyView(ActivityIndicator(isAnimating: .constant(true), style: .large))
            } else {
                return AnyView(signInScreen)
            }
        } else {
            return AnyView(ProfileView(signInViewModel: signInViewModel, iapManager: iapManager))
        }
    }

    var signInLabelWithGrayFlag: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: -20) {
                Image("grayFlag")
                    .resizable()
                    .frame(width: 121, height: 112)

                Text(NSLocalizedString("Sign in to access all Flag features!", comment: "Sign in to access all Flag features!"))
                    .font(Font.custom("Heebo-Bold", size: 30))
                    .foregroundColor(Color.white)
                    .frame(minWidth: 0, maxWidth: 290)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            Spacer()
            Spacer()
        }
    }

    var createAccountButton: some View {
        Button(action: {
            print("Create account action")
        }, label: {
            Text("Create account")
                .font(Font.custom("Heebo-Medium", size: 20))
                .foregroundColor(Color.white)
                .frame(width: 280, height: 45)
            }
        )
        .background(Color("Red1"))
        .cornerRadius(6)
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 10)
    }

    var normalSignInButton: some View {
        Button(action: {
            print("Sign out")
            self.signInViewModel.logout()
        }, label: {
            Text("Sign out")
                .frame(width: 280, height: 45)
                .foregroundColor(Color.white)
            }
        )
        .frame(width: 280, height: 45)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color("Red1"), lineWidth: 1)
        )
    }

    var signInScreen: some View {
        ZStack {
            Color("Black2")
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                signInLabelWithGrayFlag
                Spacer()

                SignInWithAppleButton()
                    .frame(width: 300, height: 45)
                    .padding(.bottom, 40)
                    .onTapGesture {
                        self.signInViewModel.signInWithApple()
                    }

                // TODO: Implement it in a near future
                //createAccountButton
                //normalSignInButton
                Spacer()
            }
            .navigationBarTitle("Profile", displayMode: .inline)
        }
    }
}

// - MARK: loading indicator

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
