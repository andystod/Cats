import Foundation

struct Cat: Codable, Hashable, Identifiable {
  let id: String
  let tags: [String]
  let createdAt: Date?
  let updatedAt: Date?
  let mimetype: String?
  let size: Int?

  enum CodingKeys: String, CodingKey {
    case id = "_id"
    case tags
    case createdAt
    case updatedAt
    case mimetype
    case size
  }

  init(id: String, tags: [String] = [], createdAt: Date? = nil, updatedAt: Date? = nil, mimetype: String? = nil, size: Int? = nil) {
    self.id = id
    self.tags = tags
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.mimetype = mimetype
    self.size = size

  }

}

