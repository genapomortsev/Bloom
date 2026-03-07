import Foundation
import SwiftUI
import Combine

@MainActor
final class MockDatabase: ObservableObject {
    static let shared = MockDatabase()
    let objectWillChange = ObservableObjectPublisher()

    @Published var currentAccount: Account
    @Published private(set) var products: [Product]
    @Published private(set) var reviews: [Review]
    @Published private(set) var likes: [Like]

    private init() {
        let demoUser = Account(username: "gena", displayName: "Gena P.")
        self.currentAccount = demoUser

        // Sample products
        let p1 = Product(name: "Hydrating Cleanser", brand: "CeraVe", category: "Cleanser", description: "Gentle, non-foaming cleanser for daily use.")
        let p2 = Product(name: "Vitamin C Serum 15%", brand: "La Roche-Posay", category: "Serum", description: "Brightening antioxidant serum with pure vitamin C.")
        let p3 = Product(name: "Niacinamide 10% + Zinc", brand: "The Ordinary", category: "Serum", description: "Helps reduce the look of blemishes and congestion.")
        let p4 = Product(name: "Daily Moisturizing Lotion", brand: "CeraVe", category: "Moisturizer", description: "Lightweight lotion with ceramides and hyaluronic acid.")
        let p5 = Product(name: "SPF 50 Sunscreen", brand: "Supergoop!", category: "Sunscreen", description: "Broad-spectrum sunscreen for daily protection.")
        let p6 = Product(name: "Retinol 0.5%", brand: "Paula's Choice", category: "Treatment", description: "Advanced retinol treatment for fine lines.")
        let p7 = Product(name: "Hyaluronic Acid Serum", brand: "The Inkey List", category: "Serum", description: "Hydrates and plumps skin with multi-molecular hyaluronic acid.")
        let p8 = Product(name: "Glycolic Acid Toner", brand: "Pixi", category: "Toner", description: "Exfoliating toner to brighten and smooth skin texture.")

        self.products = [p1, p2, p3, p4, p5, p6, p7, p8]

        // Sample reviews
        self.reviews = [
            Review(productId: p1.id, authorId: demoUser.id, rating: 5, text: "Super gentle, my skin feels clean but not tight."),
            Review(productId: p2.id, authorId: demoUser.id, rating: 4, text: "Nice glow after a week of use."),
            Review(productId: p7.id, authorId: demoUser.id, rating: 5, text: "Instantly hydrating — layers well under moisturizer."),
            Review(productId: p8.id, authorId: demoUser.id, rating: 3, text: "Effective but a bit strong — I use it only twice a week."),
        ]

        // Sample likes
        self.likes = [
            Like(productId: p1.id, accountId: demoUser.id),
            Like(productId: p5.id, accountId: demoUser.id),
            Like(productId: p7.id, accountId: demoUser.id),
        ]
    }

    // MARK: - Queries

    func searchProducts(query: String) -> [Product] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return products }
        return products.filter { product in
            product.name.lowercased().contains(q) ||
            product.brand.lowercased().contains(q) ||
            product.category.lowercased().contains(q) ||
            product.description.lowercased().contains(q)
        }
    }

    func reviews(for product: Product) -> [Review] {
        reviews.filter { $0.productId == product.id }.sorted { $0.createdAt > $1.createdAt }
    }

    func averageRating(for product: Product) -> Double {
        let rs = reviews(for: product)
        guard !rs.isEmpty else { return 0 }
        let sum = rs.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(rs.count)
    }

    func isLiked(_ product: Product, by account: Account) -> Bool {
        likes.contains { $0.productId == product.id && $0.accountId == account.id }
    }

    // MARK: - Mutations

    func toggleLike(_ product: Product) {
        let account = currentAccount
        if let idx = likes.firstIndex(where: { $0.productId == product.id && $0.accountId == account.id }) {
            likes.remove(at: idx)
        } else {
            likes.append(Like(productId: product.id, accountId: account.id))
        }
        objectWillChange.send()
    }

    func addReview(for product: Product, rating: Int, text: String) {
        let review = Review(productId: product.id, authorId: currentAccount.id, rating: rating, text: text)
        reviews.append(review)
        objectWillChange.send()
    }
}
