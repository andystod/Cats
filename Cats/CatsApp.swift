import ComposableArchitecture
import SwiftUI

@main
struct CatsApp: App {
  let store = StoreOf<CatsListFeature>(initialState: CatsListFeature.State()) {
    CatsListFeature()
  }

  var body: some Scene {
    WindowGroup {
      CatsListView(store: store)
    }
  }
}
