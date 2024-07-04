import SwiftUI

struct ImageDetailView: View {
    
    @Binding var selectedImage: String?
    var id: String
    var imageDetailAnimation: Namespace.ID
    
    @State private var dragOffsetY: CGFloat = .zero
    @State private var topBarVisible: Bool = true
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragOffsetY = value.translation.height
            }
            .onEnded { value in
                let translationX = value.translation.height
                withAnimation(.spring(duration: 0.35)) {
                    if translationX > 200 {
                        selectedImage = nil
                    }
                    dragOffsetY = 0
                }
            }
    }
    
    var body: some View {
        if let selectedImage {
            GeometryReader { proxy in
                Image(selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: id, in: imageDetailAnimation)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.2)) {
                            topBarVisible.toggle()
                        }
                    }
                    .clipped()
                    
                    .offset(y: max(0, dragOffsetY))
                    .highPriorityGesture(drag)
            }
            
            .background(.background)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Button {
                    withAnimation(.spring(duration: 0.35)) {
                        self.selectedImage = nil
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(height: 35)
                }
                .tint(.primary)
                .padding(.leading)
                .fontWeight(.semibold)
                .frame(width: 30, height: 35)
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var imageDetailAnimation
    @Previewable @State var selectedImage: String? = User.mockData.first!.profilePicture
    ImageDetailView(selectedImage: $selectedImage,
                    id: "mock_image",
                    imageDetailAnimation: imageDetailAnimation)
}
