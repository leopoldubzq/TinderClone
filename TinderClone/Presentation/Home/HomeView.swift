import SwiftUI

struct HomeView: View {
    
    @State private var users: [User] = User.mockData
    @State private var route: [Route] = []
    @Namespace private var userDetailAnimation
    
    var body: some View {
        NavigationStack(path: $route) {
            VStack {
                HStack {
                    Image("tinder_logo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fit)
                    Text("Tinder")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                if !users.isEmpty {
                    ZStack {
                        ForEach(users.reversed(), id: \.id) { user in
                            let cardIsVisible = route.isEmpty && users.reversed().first?.id == user.id
                            UserCardView(user: user,
                                         userDetailAnimation: userDetailAnimation,
                                         cardIsVisible: cardIsVisible,
                                         onSwipe: {
                                remove(user)
                            }, onTap: { visibleIndex in
                                route.append(.userDetail(user: user, imageIndex: visibleIndex))
                            })
                            .frame(height: 600)
                            .padding(.horizontal)
                        }
                    }
                } else {
                    ContentUnavailableView("No users", systemImage: "questionmark")
                }
                Spacer()
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { destination in
                switch destination {
                case .userDetail(let user, let imageIndex):
                    UserDetailView(user: user, imageIndex: imageIndex)
                        .navigationTransition(
                            .zoom(
                                sourceID: user.id,
                                in: userDetailAnimation
                            )
                        )
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color("CustomBackground"))
        }
    }
    
    private func remove(_ user: User) {
        users.removeAll(where: { $0.id == user.id })
    }
}

#Preview {
    HomeView()
}
