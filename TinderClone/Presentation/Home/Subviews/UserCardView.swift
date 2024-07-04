import SwiftUI

enum DragDirection {
    case left
    case right
    case none
}

enum SwipeTextKind {
    case like
    case reject
    
    var title: String {
        switch self {
        case .like:
            "LIKE"
        case .reject:
            "NOPE"
        }
    }
    var color: Color {
        switch self {
        case .like:
                .green
        case .reject:
                .red
        }
    }
    var degrees: CGFloat {
        switch self {
        case .like:
            -30
        case .reject:
            30
        }
    }
}

struct UserCardView: View {
    
    var user: User
    var userDetailAnimation: Namespace.ID
    @State var cardIsVisible: Bool = true
    var onSwipe: () -> ()
    var onTap: (Int) -> ()
    
    init(user: User, userDetailAnimation: Namespace.ID, 
         cardIsVisible: Bool, onSwipe: @escaping () -> Void,
         onTap: @escaping (Int) -> Void) {
        self.user = user
        self.userDetailAnimation = userDetailAnimation
        self._cardIsVisible = State(wrappedValue: cardIsVisible)
        self.onSwipe = onSwipe
        self.onTap = onTap
    }
    
    @State private var dragTranslation: CGFloat = .zero
    @State private var visiblePictureIndex: Int = 0
    @GestureState private var isLongPressing: Bool = false
    @State private var dragDirection: DragDirection = .none
    @State private var showFullInterests: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let translationX = value.translation.width
                dragTranslation = translationX
                cardIsVisible = false
                dragDirection = translationX > 0 ? .right : .left
            }
            .onEnded { value in
                let translationX = value.translation.width
                dragDirection = .none
                withAnimation(.spring(duration: 0.35)) {
                    let swipeValue: CGFloat = translationX > 0 ? 500 : -500
                    dragTranslation = abs(translationX) < 200 ? .zero : swipeValue
                } completion: {
                    cardIsVisible = true
                    guard abs(translationX) >= 200 else {
                        return
                    }
                    onSwipe()
                }
            }
    }
    
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var visiblePictureProgress: Float = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            Image(user.pictureNames[visiblePictureIndex])
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            .linearGradient(colors: [
                                Color(.black).opacity(0.8),
                                Color(.black).opacity(0.7),
                                Color(.black).opacity(0.6),
                                Color(.black).opacity(0.5),
                                Color(.black).opacity(0.4),
                                Color(.black).opacity(0.2),
                                Color(.black).opacity(0.1)
                            ], startPoint: .bottom, endPoint: .center)
                        )
                }
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("\(user.name), \(user.age)")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("\(user.distance) \(user.distance == 1 ? "kilometer" : "kilometers") away")
                            .font(.system(size: 15))
                        
                        
                        TagLayout(alignment: .leading, spacing: 6) {
                            ForEach(getUserInterests(), id: \.self) { interest in
                                InterestRowView(interest: interest)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if user.interests.count > 5 {
                            HStack(spacing: 2) {
                                Text(showFullInterests ? "Show less" : "Show more")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.init(uiColor: .label))
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .scaleEffect(0.8)
                                    .rotationEffect(.degrees(showFullInterests ? -180 : 0))
                            }
                            
                            .padding(6)
                            .padding(.horizontal, 3)
                            .background(
                                Capsule()
                                    .fill(Color.init(uiColor: .tertiarySystemGroupedBackground))
                            )
                            .background(
                                Capsule()
                                    .stroke(lineWidth: 2)
                                    .fill(Color.primary)
                            )
                            .onTapGesture {
                                showFullInterests.toggle()
                            }
                        }
                        ActionButtons()
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.spring(duration: 0.35), value: showFullInterests)
                }
                .overlay(alignment: .top) {
                    if user.pictureNames.count > 1 {
                        VisibleImageProgressIndicator()
                    }
                }
                .overlay(alignment: .topLeading) {
                    if dragDirection == .right {
                        SwipeText(.like)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if dragDirection == .left {
                        SwipeText(.reject)
                    }
                }
                .clipShape(.rect(cornerRadius: 12))
                .contentShape(.rect)
                .onTapGesture {
                    onTap(visiblePictureIndex)
                }
                .matchedTransitionSource(id: user.id, in: userDetailAnimation) { configuration in
                    configuration
                        .clipShape(.rect(cornerRadius: 12))
                        .background(Color("CustomBackground"))
                }
                .offset(x: dragTranslation)
                .rotationEffect(.degrees(max(-10, min(10, dragTranslation * 0.05))))
                .highPriorityGesture(dragGesture)
                .onReceive(timer) { _ in
                    handleVisibleImageTimeProgress()
                }
                .onDisappear {
                    cardIsVisible = false
                }
                .onAppear {
                    cardIsVisible = true
                }
        }
    }
    
    private func handleVisibleImageTimeProgress() {
        guard cardIsVisible else {
            return
        }
        if visiblePictureProgress < 1.0 {
            visiblePictureProgress += 0.002
        } else {
            if visiblePictureIndex < user.pictureNames.count - 1 {
                visiblePictureIndex += 1
            } else {
                visiblePictureIndex = 0
            }
            visiblePictureProgress = 0
        }
    }
    
    private func getUserInterests() -> [String] {
        if user.interests.count >= 5 && !showFullInterests {
            return Array(user.interests[0...4])
        } else {
            return user.interests
        }
    }
    
    private func swipe(_ direction: DragDirection) {
        withAnimation(.spring(duration: 0.35)) {
            switch direction {
            case .left:
                dragTranslation = -500
            case .right:
                dragTranslation = 500
            case .none:
                break
            }
        } completion: {
            onSwipe()
        }
    }
    
    @ViewBuilder
    private func SwipeText(_ kind: SwipeTextKind) -> some View {
        Text(kind.title)
            .font(.system(size: 45))
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 4)
            }
            .padding(32)
            .foregroundStyle(kind.color)
            .padding(.top, 24)
            .rotationEffect(.degrees(kind.degrees))
            .opacity(abs(dragTranslation * 0.01))
    }
    
    @ViewBuilder
    private func ActionButtons() -> some View {
        GeometryReader {
            let size = $0.size
            VStack(alignment: .center) {
                HStack(spacing: 32) {
                    Button { swipe(.left) } label: {
                        Image("reject_icon")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(dragDirection == .left ? .white : .red)
                            .frame(width: 18, height: 18)
                            .background {
                                Circle()
                                    .fill(dragDirection == .left ? .red : .white)
                                    .frame(width: size.height, height: size.height)
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .scaleEffect(1.2 + min(0.25, max(0, -dragTranslation * 0.008)))
                    
                    Button {} label: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.blue.gradient)
                            .frame(width: size.height, height: size.height)
                            .background {
                                Circle()
                                    
                            }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button { swipe(.right) } label: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(dragDirection == .right ? Color.white : Color.green)
                            .frame(width: size.height, height: size.height)
                            .animation(.spring(duration: 0.2), value: dragDirection)
                            .background { Circle().fill(dragDirection == .right ? .green : .white) }
                    }
                    .frame(maxWidth: .infinity)
                    .scaleEffect(1.2 + min(0.25, max(0, dragTranslation * 0.008)))
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 44)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func VisibleImageProgressIndicator() -> some View {
        HStack(spacing: 4) {
            ForEach(user.pictureNames.indices, id: \.self) { index in
                GeometryReader {
                    let size = $0.size
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.secondary)
                        if index == visiblePictureIndex {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .frame(width: size.width * CGFloat(visiblePictureProgress))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

#Preview {
    @Previewable @Namespace var userDetailAnimation
    UserCardView(user: User.mockData.first!,
                 userDetailAnimation: userDetailAnimation,
                 cardIsVisible: true,
                 onSwipe: {}, onTap: { _ in })
        .frame(height: 600)
        .padding(.horizontal)
}


