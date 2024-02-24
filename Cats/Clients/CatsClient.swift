import ComposableArchitecture
import Foundation

struct CatsClient {
  var fetchAllCats: () async throws -> [Cat]

  var fetchCatById: (String) async throws -> Cat
}

extension CatsClient: DependencyKey {
  static let liveValue = Self(
    fetchAllCats: {
      let (data, response) = try await URLSession.shared
        .data(from: URL(string: "https://cataas.com/api/cats")!)

      try await Task.sleep(for: .seconds(2))

      return [Cat(id: "af423")]
    },

    fetchCatById: { id in
      let (data, response) = try await URLSession.shared
        .data(from: URL(string: "https://cataas.com/cat/\(id)?width=50&height=50")!)
      let cat = try JSONDecoder().decode(Cat.self, from: data)
      return cat
    }
  )
}

extension DependencyValues {
  var catsClient: CatsClient {
    get { self[CatsClient.self] }
    set { self[CatsClient.self] = newValue }
  }
}
