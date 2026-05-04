import SwiftUI

struct HomeView: View {
    
    @State private var users: [User] = User.mockData
    @Environment(NavigationManager.self) private var navigationManager
    @Namespace private var userDetailNamespace
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        NavigationStack(path: $navigationManager.route) {
            VStack {
                HStack {
                    Image("tinder_logo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                    Text("Avenger")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                if !users.isEmpty {
                    ZStack {
                        ForEach(users.reversed(), id: \.id) { user in
                            let cardIsVisible = cardIsVisible(user: user)
                            UserCardView(
                                user: user,
                                userDetailNamespace: userDetailNamespace,
                                cardIsVisible: cardIsVisible,
                                onSwipe: { remove(user) },
                                onTap: { visibleIndex in
                                    navigate(
                                        to: user,
                                        visibleIndex: visibleIndex
                                    )
                                }
                            )
                            .frame(height: 600)
                            .padding(.horizontal)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No users",
                        systemImage: "questionmark"
                    )
                }
                Spacer()
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { destination in
                switch destination {
                case .userDetail(let user, let imageIndex):
                    UserDetailView(
                        user: user,
                        imageIndex: imageIndex
                    )
                    .navigationTransition(
                        .zoom(
                            sourceID: user.id,
                            in: userDetailNamespace
                        )
                    )
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color.customBackground)
        }
    }
    
    private func remove(_ user: User) {
        users.removeAll(where: { $0.id == user.id })
    }
    
    private func cardIsVisible(user: User) -> Bool {
        navigationManager.route.isEmpty && users.reversed().first?.id == user.id
    }
    
    private func navigate(to user: User, visibleIndex: Int) {
        navigationManager.push(
            .userDetail(
                user: user,
                imageIndex: visibleIndex
            )
        )
    }
}

#Preview {
    HomeView()
        .environment(NavigationManager())
}
