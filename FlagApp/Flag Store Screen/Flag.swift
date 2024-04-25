import SwiftUI

public struct FlagCard: View {
    let flagName: String
    init(flagName: String) {
        self.flagName = flagName
    }
    public var body: some View {
        VStack {
            Image("grayFlag")
                .resizable()
                .padding(15)
            Text(flagName)
                .font(Font.custom("Heebo-Light", size: 15))
                .padding(.horizontal, 15)
        }
    }
}

struct Flag_Previews: PreviewProvider {
    static var previews: some View {
        FlagCard(flagName: "Brazil")
    }
}
