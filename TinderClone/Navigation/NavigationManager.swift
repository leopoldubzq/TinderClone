import Observation
import SwiftUI

@Observable
final class NavigationManager: NavigationManageable {
    var route: [Route] = []
}
