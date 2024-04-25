import SwiftUI

struct SettingsView: View {
    var rows = [
        Row(image: "activity", title: "Your activity"),
        Row(image: "notification", title: "Notifications"),
        Row(image: "accessibility", title: "Accessibility"),
        Row(image: "account", title: "Account"),
        Row(image: "help", title: "Help and support"),
        Row(image: "aboutUs", title: "About us")
    ]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        ForEach(self.rows, id: \.self) { row in
                            NavigationLink(
                                destination: Text("TODO"),
                                label: {
                                    RowView(row: row)
                                        .frame(height: 50)
                                        .background(Color("Black1"))
                                }
                            )
                                .padding(.trailing, 20)
                                .background(Color("Black1"))
                        }
                    }

                    Section(
                        header: Text("Logins").modifier(
                            SectionHeader(
                                backgroundColor: Color("Black2"),
                                foregroundColor: Color.white
                            )
                        )
                    ) {
                        NavigationLink(
                            destination: Text("TODO"),
                            label: {
                                self.loginInformationRow
                                    .frame(height: 50)
                                    .background(Color("Black1"))
                            }
                        )
                            .padding(.trailing, 20)
                            .background(Color("Black1"))

                        self.addAccountRow
                        self.logoutRow
                    }
                }
                    .foregroundColor(Color.white)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.top, 18)
                    .navigationBarTitle("Settings", displayMode: .inline )

                Spacer()
            }
            .background(Color("Black2"))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    private var addAccountRow: some View {
        Button(
            action: { print("TODO: Implement add account") },
            label: {
                Text("Add account")
                    .frame(height: 50)
                    .foregroundColor(Color("Red1"))
                    .padding(.leading, 12)
            }
        )
    }

    private var logoutRow: some View {
        Button(
            action: { print("TODO: Implement logout") },
            label: {
                Text("Logout")
                    .frame(height: 50)
                    .foregroundColor(Color("Red1"))
                    .padding(.leading, 12)
            }
        )
    }

    struct SectionHeader: ViewModifier {
        var backgroundColor: Color
        var foregroundColor: Color
        func body(content: Content) -> some View {
            content
            .padding(20)
            .frame(
                width: UIScreen.main.bounds.width,
                height: 50,
                alignment: .leading
            )
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
        }
    }

    private var loginInformationRow: some View {
        HStack {
            Text("Login information")
                .padding(.leading, 12)
        }
    }

    private struct RowView: View {
        private let row: Row
        init(row: Row) {
            self.row = row
        }
        var body: some View {
            HStack(spacing: 23) {
                Image(self.row.image)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(Color.white)
                    .padding(.leading, 12)

                Text(self.row.title)
                    .foregroundColor(Color.white)

                Spacer()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct Row: Hashable {
    let image: String
    let title: String
}
