// Note this would be broken into separate when
// the need arises (ie more content complication)

import Foundation
import ComposableArchitecture
import Kingfisher

@Reducer
struct CatDetailsFeature {
  @ObservableState
  struct State {
    var isLoading: Bool = false
    let catId: String
    var cat: Cat?
  }
  enum Action {
    case onAppear
    case fetchCatResponse(Result<Cat, Error>)
  }
  @Dependency(\.catsClient) var catsClient
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
//        guard let catId = state.cat?.id else { return .none }
        //
        //        let cat = try await self.catsClient.fetchCatById(catId)

        //        let cats = try! await self.catsClient.fetchAllCats()
        return .run { [catId = state.catId] send in
          do {
            let cat = try await self.catsClient.fetchCatById(catId)
            await send(.fetchCatResponse(.success(cat)))
          } catch {
            await send(.fetchCatResponse(.failure(error)))
          }
        }
        //        return .run { send in
        //          send.callAsFunction()
        //        }
      case .fetchCatResponse(.success(let cat)):
        state.isLoading = false
        state.cat = cat
        return .none

      case .fetchCatResponse(.failure(let error)):
        print("fetchCatResponse error: \(error)") // TODO
        state.isLoading = false
        state.cat = nil
        return .none
      }
    }
  }
}


import SwiftUI

struct CatDetailsView: View {
  @Perception.Bindable var store: StoreOf<CatDetailsFeature>

//  let cat = store.state

  var body: some View {
    WithPerceptionTracking {
      List {
        KFImage(URL(string: "https://cataas.com/cat/\(store.state.catId)?width=400&height=400")!)
          .placeholder {
            ProgressView()
          }
          .resizable()
          .aspectRatio(contentMode: .fit)

        Text(store.state.catId)

        if let cat = store.state.cat {
          ForEach(cat.tags, id: \.self) { tag in
            Text("Tag: \(tag)")
          }
          if let mimetype = cat.mimetype {
            Text("Mime Type: \(mimetype)")
          }
          if let size = cat.size {
            Text("Size: \(size)")
          }
          if let createdAt = cat.createdAt {
            Text("createdAt: \(createdAt)")
          }
          if let editedAt = cat.editedAt {
            Text("editedAt: \(editedAt)")
          }
        }
      }
      .navigationTitle("Cat Details")
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}


#Preview {
  CatDetailsView(store: StoreOf<CatDetailsFeature>(
    initialState: CatDetailsFeature.State(
      isLoading: false,
      catId: "fsdfsd",
      cat: nil
    ), reducer: {
      CatDetailsFeature()
    })
  )
}
