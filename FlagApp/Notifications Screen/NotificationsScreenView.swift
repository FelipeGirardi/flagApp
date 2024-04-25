import SwiftUI

struct NotificationsScreenView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("Black2")
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle(Text("Notifications"))
        }
    }
}

struct NotificationsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsScreenView()
    }
}
