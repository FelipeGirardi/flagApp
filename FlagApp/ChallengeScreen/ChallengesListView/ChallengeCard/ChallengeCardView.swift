import SwiftUI

struct ChallengeCardView: View {
    // MARK: mock ChallengeInfo object
    var challengeInfo: ChallengeInfo

    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)

            HStack(spacing: 20) {
                Spacer()
                    .frame(width: 100)

                VStack(alignment: .leading) {
                    Text(challengeInfo.challengeName)
                        .font(Font.custom("Heebo-Medium", size: 21))
                        .foregroundColor(Color("White2"))

                    Text(challengeInfo.challengeShortDescription)
                        .font(Font.custom("Heebo-Light", size: 15))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("White2"))
                }
                Spacer()
            }
            .frame(height: 100)
            .background(
                BlurChallengeList()
                    .opacity(0.9)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#331481"), Color(hex: "#7F47DC")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .opacity(0.7)
                    )
            )
            .cornerRadius(20)
            .padding(.top, 50)

            HStack(spacing: 70) {
                Image(challengeInfo.challengeImageString)
                    .resizable()
                    .frame(width: 105, height: 137, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 3)
                    .padding(.leading, 8)

                Spacer()
            }
            .frame(height: 117)
        }
    }
}

struct BlurChallengeList: UIViewRepresentable {
    let style: UIBlurEffect.Style = .light

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return blur
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
