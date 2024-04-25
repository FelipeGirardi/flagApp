import AuthenticationServices
import SwiftUI

struct SignInWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        SignInWithAppleButtonInternal(colorScheme: .dark)
    }
}

private struct SignInWithAppleButtonInternal: UIViewRepresentable {
    var colorScheme: ColorScheme

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        switch colorScheme {
        case .light:
            return ASAuthorizationAppleIDButton(type: .signIn, style: .black)

        case .dark:
            return ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        @unknown default:
            return ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        }
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

struct SignInWithAppleButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleButton()
    }
}
