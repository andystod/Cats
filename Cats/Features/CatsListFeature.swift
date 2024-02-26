// Note this would be broken into separate when
// the need arises (ie more content complication)


import ComposableArchitecture
import Foundation

@Reducer
struct CatsListFeature {
  @ObservableState
  struct State {
    var cats = [Cat]()
    var isLoading = false
    var path = StackState<CatDetailsFeature.State>()
  }
  enum Action {
    case onAppear
    case fetchAllCatsResponse(Result<[Cat], Error>)
    case path(StackAction<CatDetailsFeature.State, CatDetailsFeature.Action>)
  }
  @Dependency(\.catsClient) var catsClient
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { send in
          do {
            let cats = try await self.catsClient.fetchAllCats()
            await send(.fetchAllCatsResponse(.success(cats)))
          } catch {
            await send(.fetchAllCatsResponse(.failure(error)))
          }
        }
      case .fetchAllCatsResponse(.success(let cats)):
        state.cats = cats
        state.isLoading = false
        return .none

      case .fetchAllCatsResponse(.failure):
        state.cats = []
        state.isLoading = false
        return .none

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      CatDetailsFeature()
    }
  }
}

import SwiftUI

struct CatsListView: View {
  @Perception.Bindable var store: StoreOf<CatsListFeature>
//  @Bindable var store: StoreOf<CatsListFeature>

  var body: some View {
    WithPerceptionTracking {
      NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
        VStack {
          if store.isLoading {
            ProgressView()
              .progressViewStyle(.circular)
              .controlSize(.large)
              .foregroundStyle(Color.red)
          }
          List {
            ForEach(store.cats) { cat in
              NavigationLink(state: CatDetailsFeature.State(catId: cat.id)) {
                Text(cat.id)
              }
            }
          }
        }
      } destination: { store in
        CatDetailsView(store: store)
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}


#Preview {
  CatsListView(store: StoreOf<CatsListFeature>(
    initialState: CatsListFeature.State(
      cats: [
        Cat(id: "423"),
        Cat(id: "454")
      ],
      isLoading: true
    ), reducer: {
    CatsListFeature()
  }))
}
