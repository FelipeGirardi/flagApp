import SwiftUI

struct TrendingView: View {
    var trendingInfo: TrendingInfo

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(trendingInfo.sectionName)
                    .font(Font.custom("Heebo-Medium", size: 18))
                    .foregroundColor(Color("White1"))

                Spacer()

                Button(action: {
                    // Action
                }, label: {
                    Text("See all")
                        .font(Font.custom("Heebo-Light", size: 14))
                        .foregroundColor(Color("Red1"))
                }
                )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    // Placeholder images for now, will change when we have a model for each trending section
                    Image(trendingInfo.imageStrings[0])
                        .resizable()
                        .frame(width: 222, height: 140)    // temporary frame
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)

                    Image(trendingInfo.imageStrings[1])
                        .resizable()
                        .frame(width: 222, height: 140)    // temporary frame
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 0))
    }
}

struct TrendingView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingView(trendingInfo: TrendingInfo(sectionName: "Trending music videos", imageStrings: ["MockMusicVideo1", "MockMusicVideo2"]))
    }
}
