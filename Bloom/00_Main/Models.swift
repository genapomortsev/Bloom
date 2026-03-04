import Foundation
import SwiftUI

struct Account: Identifiable, Hashable, Codable {
    let id: UUID
    var username: String
    var displayName: String
    var avatarSystemImage: String

    init(id: UUID = UUID(), username: String, displayName: String, avatarSystemImage: String = "person.circle") {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarSystemImage = avatarSystemImage
    }
}

struct Product: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var brand: String
    var category: String
    var description: String

    init(id: UUID = UUID(), name: String, brand: String, category: String, description: String) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.description = description
    }
}

struct Review: Identifiable, Hashable, Codable {
    let id: UUID
    let productId: UUID
    let authorId: UUID
    var rating: Int // 1..5
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), productId: UUID, authorId: UUID, rating: Int, text: String, createdAt: Date = .now) {
        self.id = id
        self.productId = productId
        self.authorId = authorId
        self.rating = max(1, min(5, rating))
        self.text = text
        self.createdAt = createdAt
    }
}

struct Like: Identifiable, Hashable, Codable {
    let id: UUID
    let productId: UUID
    let accountId: UUID

    init(id: UUID = UUID(), productId: UUID, accountId: UUID) {
        self.id = id
        self.productId = productId
        self.accountId = accountId
    }
}
