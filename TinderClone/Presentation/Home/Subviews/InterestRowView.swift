import SwiftUI

struct InterestRowView: View {
    
    var interest: String
    
    var body: some View {
        Text(interest)
            .font(.system(size: 14))
            .foregroundStyle(Color.init(uiColor: .label))
            .padding(6)
            .padding(.horizontal, 6)
            .background {
                if Constants.matches(interest) {
                    Capsule()
                        .fill(Color("Tinder").gradient)
                } else {
                    Capsule()
                        .fill(Color.init(uiColor: .tertiarySystemGroupedBackground))
                }
            }
    }
}

#Preview {
    @Previewable @Namespace var userDetailAnimation
    UserCardView(user: User.mockData.first!,
                 userDetailAnimation: userDetailAnimation,
                 cardIsVisible: true,
                 onSwipe: {},
                 onTap: { _ in })
    .frame(height: 600)
    .padding(.horizontal)
}
