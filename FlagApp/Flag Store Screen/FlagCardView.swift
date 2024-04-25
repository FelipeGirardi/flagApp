import SwiftUI

public struct FlagCardView: View {
    let flagCard: FlagCard
    @ObservedObject private var viewModel: FlagStoreViewModel

    init(flagCard: FlagCard, viewModel: FlagStoreViewModel) {
        self.flagCard = flagCard
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            if (self.viewModel.userManager.profile?.boughtFlagsIDs ?? []).contains(self.flagCard.id) {
                boughtFlagCell(geometry: geometry)
            } else {
                notBoughtFlagCell(geometry: geometry)
            }
        }
    }

    func boughtFlagCell(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                Image("redCheckmark")
                    .resizable()
                    .frame(width: 11, height: 8)
                    .padding([.top, .trailing], 9)
            }
            .opacity(isFlagSelected() ? 1.0 : 0.0)

            Image(flagCard.imageName)
                .resizable()
                .frame(
                    width: geometry.size.width * 0.8,
                    height: geometry.size.height * 0.53
                )

            Text(flagCard.name)
                .font(Font.custom("Heebo-Light", size: 12))
                .padding(.horizontal, 5)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .lineSpacing(-10)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.34)

            Spacer()
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
        .onTapGesture {
            if !isFlagSelected() {
                // assign flag here already to show faster
                self.viewModel.myFlagAssetName = self.flagCard.imageName
                self.viewModel.selectedFlag? = self.flagCard
                self.viewModel.userManager.profile?.profileSelectedFlagName = self.flagCard.imageName
                self.viewModel.selectFlag(flagName: self.flagCard.imageName)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isFlagSelected() ? Color("Red1") : Color("Gray6"), lineWidth: isFlagSelected() ? 2 : 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Gray4"))
        )
    }

    func notBoughtFlagCell(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                Image("peakTokenBig")
                    .resizable()
                    .frame(width: 16, height: 16)
                Text("\(flagCard.price)")
                    .font(Font.custom("Heebo-Medium", size: 12))
                    .foregroundColor(Color(hex: "#70E0FB"))
                    .padding(.trailing, 10)
                Spacer()
            }
            .frame(width: geometry.size.width, height: 20)
            .padding(.vertical, 5)

            Image(flagCard.imageName)
                .resizable()
                .frame(
                    width: geometry.size.width * 0.6,
                    height: geometry.size.height * 0.43
                )

            Text(flagCard.name)
                .font(Font.custom("Heebo-Light", size: 12))
                .padding(.horizontal, 5)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .lineSpacing(-10)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.34)

            Spacer()
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
        .onTapGesture {
            if hasEnoughCash() {
                viewModel.isShowingBuyFlagView = true
                viewModel.selectedFlagToBuy = flagCard
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("Gray4"), lineWidth: 1)
        )
        .opacity(hasEnoughCash() ? 1.0 : 0.6)
    }

    func isFlagSelected() -> Bool {
        self.viewModel.myFlagAssetName == self.flagCard.imageName
    }

    func hasEnoughCash() -> Bool {
        (self.viewModel.userManager.profile?.cash ?? 0) >= self.flagCard.price
    }
}
