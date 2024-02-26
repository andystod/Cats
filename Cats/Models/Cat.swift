import Foundation

struct Cat: Codable, Hashable, Identifiable {
  let id: String
  let tags: [String]
  let createdAt: Date?
  let editedAt: Date?
  let mimetype: String?
  let size: Int?

  enum CodingKeys: String, CodingKey {
    case id = "_id"
    case tags
    case createdAt
    case editedAt
    case mimetype
    case size
  }

  init(id: String, tags: [String] = [], createdAt: Date? = nil, editedAt: Date? = nil, mimetype: String? = nil, size: Int? = nil) {
    self.id = id
    self.tags = tags
    self.createdAt = createdAt
    self.editedAt = editedAt
    self.mimetype = mimetype
    self.size = size
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    tags = try container.decode([String].self, forKey: .tags)
    mimetype = try container.decodeIfPresent(String.self, forKey: .mimetype)
    size = try container.decodeIfPresent(Int.self, forKey: .size)

    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
      createdAt = dateFormatter.date(from: createdAtString)
    } else {
      createdAt = nil
    }

    if let editedAtString = try container.decodeIfPresent(String.self, forKey: .editedAt) {
      editedAt = dateFormatter.date(from: editedAtString)
    } else {
      editedAt = nil
    }
  }
}

