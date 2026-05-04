import SwiftUI

struct UserDetailView: View {
    
    var user: User
    var imageIndex: Int
    
    @State private var scrollOffsetY: CGFloat = .zero
    @State private var scrollOffsetX: CGFloat = .zero
    @State private var visibleHorizontalIndex: Int = 0
    @State private var scrollPosition: ScrollPosition = .init(idType: String.self)
    @State private var selectedImage: String?
    @Namespace private var imageDetailAnimation
    
    init(user: User, imageIndex: Int) {
        self.user = user
        self.imageIndex = imageIndex
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(user.pictureNames, id: \.self) { imageName in
                                ProfileImage(imageName: imageName)
                                    .frame(width: proxy.size.width)
                                    .onScrollVisibilityChange { isVisible in
                                        if isVisible {
                                            guard let visibleIndex = user.pictureNames.firstIndex(of: imageName) else {
                                                return
                                            }
                                            self.visibleHorizontalIndex = visibleIndex
                                        }
                                    }
                            }
                        }
                    }
                    .scrollPosition($scrollPosition)
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.paging)
                    .scrollClipDisabled()
                    .frame(
                        height: proxy.size.height * 0.65 +
                        proxy.safeAreaInsets.top +
                        proxy.safeAreaInsets.bottom
                    )
                    .overlay(alignment: .bottom) {
                        if user.pictureNames.count > 1 {
                            HStack {
                                ForEach(user.pictureNames.indices, id: \.self) { index in
                                    Circle()
                                        .fill(visibleHorizontalIndex == index ? .primary : .secondary)
                                        .animation(.easeInOut(duration: 0.1), value: visibleHorizontalIndex)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 8)
                        }
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.x
                    } action: { _, newValue in
                        scrollOffsetX = newValue
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("\(user.name), \(user.age)")
                                .font(.title)
                                .fontWeight(.semibold)
                            Text("\(user.distance) \(user.distance == 1 ? "kilometer" : "kilometers") away")
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("About me")
                                    .font(.headline)
                                Text(user.bio)
                                    .foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Interests")
                                    .font(.headline)
                                TagLayout(alignment: .leading) {
                                    ForEach(user.interests, id: \.self) { interest in
                                        InterestRowView(interest: interest)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea()
            .navigationTitle(user.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(selectedImage != nil ? .hidden : .visible, for: .navigationBar)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, newValue in
                scrollOffsetY = newValue
            }
            .overlay {
                if selectedImage != nil {
                    ImageDetailView(selectedImage: $selectedImage,
                                    id: selectedImage!,
                                    imageDetailAnimation: imageDetailAnimation)
                }
            }
            .onAppear {
                scrollPosition.scrollTo(id: user.pictureNames[imageIndex])
            }
        }
        .background(Color.customBackground)
        
    }
    
    private func getXOffset(proxy: GeometryProxy) -> CGFloat {
        if scrollOffsetX < 0 {
            return scrollOffsetX
        } else if scrollOffsetX > (proxy.size.width * CGFloat(user.pictureNames.count - 1)) {
            let currentOffsetX = (proxy.size.width * CGFloat(user.pictureNames.count - 1))
            return scrollOffsetX - currentOffsetX
        } else {
            return 0.0
        }
    }
    
    @ViewBuilder
    private func ProfileImage(imageName: String) -> some View {
        GeometryReader { proxy in
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .matchedGeometryEffect(id: imageName, in: imageDetailAnimation)
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height + max(0, -scrollOffsetY)
                )
                .clipped()
                .contentShape(.rect)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(
                            .linearGradient(colors: [
                                Color(uiColor: .black).opacity(0.7),
                                Color(uiColor: .black).opacity(0.6),
                                Color(uiColor: .black).opacity(0.5),
                                Color(uiColor: .black).opacity(0.2),
                                Color(uiColor: .black).opacity(0.1),
                                Color(uiColor: .black).opacity(0.05),
                                Color(uiColor: .black).opacity(0.01)
                            ], startPoint: .top, endPoint: .center)
                        )
                }
                .offset(x: getXOffset(proxy: proxy), y: min(0, scrollOffsetY))
                .onTapGesture {
                    withAnimation(.spring(duration: 0.35)) {
                        selectedImage = imageName
                    }
                }
        }
    }
}

#Preview {
    UserDetailView(user: User.mockData.first!, imageIndex: 0)
}
