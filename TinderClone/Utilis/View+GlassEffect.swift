import SwiftUI

extension View {
    @ViewBuilder
    func glassBackground<S: Shape>(
        in shape: S = Capsule(),
        fallbackMaterial: Material = .thinMaterial
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(shape.fill(fallbackMaterial))
        }
    }

    @ViewBuilder
    func glassBackgroundTinted<S: Shape>(
        _ tint: Color,
        in shape: S = Capsule(),
        fallbackMaterial: Material = .thinMaterial
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tint), in: shape)
        } else {
            self.background(shape.fill(fallbackMaterial))
                .background(shape.fill(tint.opacity(0.15)))
        }
    }
}
