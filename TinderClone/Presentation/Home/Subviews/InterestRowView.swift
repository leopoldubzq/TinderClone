import SwiftUI

struct InterestRowView: View {

    var interest: String

    var body: some View {
        Text(interest)
            .font(.system(size: 14))
            .foregroundStyle(Color(uiColor: .label))
            .padding(6)
            .padding(.horizontal, 6)
            .background {
                if Constants.matches(interest) {
                    Capsule().fill(Color.tinder.gradient)
                } else {
                    Capsule().fill(Material.regular)
                }
            }
    }
}
