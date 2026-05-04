import SwiftUI

struct HomeView: View {
    
    @State private var users: [User] = User.mockData
    @Environment(NavigationManager.self) private var navigationManager
    @Namespace private var userDetailNamespace
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        NavigationStack(path: $navigationManager.route) {
            VStack {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image("tinder_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                        Text("Avenger")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
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
