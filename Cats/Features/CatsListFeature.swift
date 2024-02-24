import ComposableArchitecture
import Foundation

@Reducer
struct CatsListFeature {
  @ObservableState
  struct State {
    var cats = [Cat]()
    var isLoading = false
  }
  enum Action {
    case onAppear
    case fetchAllCatsResponse(Result<[Cat], Error>)
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
      }
    }
  }
}

import SwiftUI

struct CatsListView: View {
  @Perception.Bindable var store: StoreOf<CatsListFeature>
//  @Bindable var store: StoreOf<CatsListFeature>

  var body: some View {
    WithPerceptionTracking {
      VStack {
        if store.isLoading {
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.large)
            .foregroundStyle(Color.red)
        }
        List {
          ForEach(store.cats) { cat in
            Text(cat.id)
          }
        }
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
