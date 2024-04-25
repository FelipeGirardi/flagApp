import Introspect
import SwiftUI

struct FlagStoreView: View {
    @ObservedObject private var viewModel: FlagStoreViewModel
    @State var showIAPScreen: Bool = false

    init (viewModel: FlagStoreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("Black2")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 23) {
                    roundedTopBar

                    ScrollView {
                        header
                        content(geometry: geometry)
                    }
                    .frame(width: geometry.size.width)
                }
                .blur(radius: (showIAPScreen || viewModel.isShowingBuyFlagView) ? 10 : 0)

                if viewModel.isShowingBuyFlagView {
                    self.buyAlert
                        .frame(width: geometry.size.width * 0.90, height: geometry.size.height * 0.55)
                }

                if showIAPScreen {
                    IAPScreen(viewModel: IAPViewModel(userManager: self.viewModel.userManager, iapManager: self.viewModel.iapManager, showIAPScreen: self.$showIAPScreen))
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.56)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private var roundedTopBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .foregroundColor(Color("Black3"))
            .frame(width: 36, height: 5)
            .padding(.top, 15)
    }

    private func header(title: String) -> some View {
        HStack {
            Text(title)
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color("Red1"))
            Spacer()
        }
        .padding(.leading)
    }

    private var header: some View {
        VStack {
            HStack {
                Spacer()
                Spacer()
                peakTokensArea
            }

            Text(NSLocalizedString("Select a flag to represent you:", comment: "Select a flag to represent you:"))
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color("Red1"))
                .padding(.top, 20)

            ZStack {
                RoundedRectangle(cornerRadius: 68)
                    .stroke(Color("Red1"), lineWidth: 1)
                    .frame(width: 136, height: 136)

                Image(viewModel.selectedFlag?.imageName ?? "")
                    .resizable()
                    .frame(width: 90, height: 90)
            }

            Text(viewModel.selectedFlag?.name ?? "")
                .font(Font.custom("Heebo-Bold", size: 23))
                .foregroundColor(Color("Red1"))
        }
    }

    private func content(geometry: GeometryProxy) -> some View {
        ForEach(viewModel.consumableFlags, id: \.id) { consumableFlag in
            if #available(iOS 14.0, *) {
                Section(header: header(title: consumableFlag.id)) {
                    LazyVStack {
                        ForEach(0..<consumableFlag.flagRows.count) { rowIndex in
                            HStack(spacing: 0) {
                                ForEach(consumableFlag.flagRows[rowIndex], id: \.id) { flagCard in
                                    FlagCardView(flagCard: flagCard, viewModel: viewModel)
                                        .frame(width: geometry.size.width / 5, height: 115)
                                        .padding(.leading, geometry.size.width / 25)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                Section(header: header(title: consumableFlag.id)) {
                    List {
                        ForEach(0..<consumableFlag.flagRows.count) { rowIndex in
                            HStack(spacing: 0) {
                                ForEach(consumableFlag.flagRows[rowIndex], id: \.id) { flagCard in
                                    FlagCardView(flagCard: flagCard, viewModel: viewModel)
                                        .frame(width: geometry.size.width / 5, height: 115)
                                        .padding(.leading, geometry.size.width / 25)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }

    private var peakTokensArea: some View {
        HStack {
            Spacer()
            Spacer()
            HStack(spacing: 7) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(Color("Blue2"))
                        .frame(width: 118, height: 26)

                    HStack(spacing: 8) {
                        Image("peakTokenBig")
                            .resizable()
                            .frame(width: 35, height: 35)

                        Text("\(viewModel.totalCash)")
                            .foregroundColor(Color("Blue1"))
                            .font(Font.custom("Heebo-Medium", size: 22))
                    }
                    .offset(x: -20)
                }
                .frame(width: 118, height: 35)

                Button(
                    action: {
                        self.showIAPScreen = true
                    },
                    label: {
                        Image("buyTokenButton")
                            .resizable()
                    }
                )
                .frame(width: 26, height: 26)
            }
        }
        .padding(.trailing, 20)
    }

    private var buyAlert: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                buyAlertHeader

                HStack {
                    Spacer()

                    Image(viewModel.selectedFlagToBuy?.imageName ?? "grayFlag")
                        .resizable()
                        .frame(width: geometry.size.width * 0.30, height: geometry.size.height * 0.30, alignment: .center)

                    Spacer()
                }
                    .padding(.top)
                Spacer()
                VStack(spacing: 0) {
                    Text(viewModel.selectedFlagToBuy?.name ?? "Default") // flagName
                        .font(Font.custom("Heebo-Bold", size: 32))
                        .foregroundColor(Color("White1"))
                        .minimumScaleFactor(0.7)

                    Text(NSLocalizedString("Buy this item for", comment: "Buy this item for")) // flagName
                        .font(Font.custom("Heebo-Light", size: 20))
                        .foregroundColor(Color(hex: "#98989E"))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                    HStack {
                        Spacer()
                        Image("peakTokenBig")
                            .resizable()
                            .frame(width: 36, height: 36)
                        Text("\(viewModel.selectedFlagToBuy?.price ?? 0)")
                            .font(Font.custom("Heebo-Medium", size: 30))
                            .foregroundColor(Color(hex: "#70E0FB"))
                        Text("?")
                            .font(Font.custom("Heebo-Light", size: 22))
                            .foregroundColor(Color(hex: "98989E"))
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                }
                Spacer()
                buyButton
                    .background(viewModel.isBuyButtonEnabled ? Color("Red1") : Color("Gray3"))
                    .cornerRadius(8)
                    .padding(.bottom)
            }
            .background(
                Color(hex: "#1C1C1E")
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#2C2E33"), lineWidth: 1)
                    )
            )
            .cornerRadius(10)
            .padding(20)
        }
    }

    private var buyButton: some View {
        Button(
            action: {
                viewModel.buySelectedFlag()
            },
            label: {
                Group {
                    if viewModel.isBuyingFlag {
                        ActivityIndicator(isAnimating: $viewModel.isBuyingFlag, style: .medium)
                    } else {
                        Text(NSLocalizedString("BUY", comment: "BUY"))
                            .font(Font.custom("Heebo-SemiBold", size: 21))
                            .foregroundColor(Color("White1"))
                            .cornerRadius(50)
                            .minimumScaleFactor(0.8)
                            .opacity(viewModel.isBuyButtonEnabled ? 1 : 0.4)
                    }
                }
                .frame(width: 200, height: 32, alignment: .center)
            }
        )
        .disabled(viewModel.isBuyingFlag || !viewModel.isBuyButtonEnabled)
    }

    private var buyAlertHeader: some View {
        HStack {
            HStack {
                Image("TabBar-social-red-icon")
                    .resizable()
                    .frame(width: 17, height: 17)

                Text(viewModel.selectedFlagToBuy?.category ?? "Default")
                    .font(Font.custom("Heebo-Bold", size: 15))
                    .foregroundColor(Color(hex: "#98989E"))
            }
            .padding(.horizontal, 15)

            Spacer()

            Button(
                 action: {
                     // Close this view
                     print("FECHOU BUY FLAG VIEW FLAG")
                     DispatchQueue.main.async {
                         viewModel.isShowingBuyFlagView = false
                     }
                 }, label: {
                     Image("dismissChallenge-icon")
                 }
             )
             .frame(width: 40, height: 40)
             .buttonStyle(PlainButtonStyle())
        }
    }
}
