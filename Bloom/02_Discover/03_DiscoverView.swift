import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var db: MockDatabase
    @State private var query: String = ""
    @State private var presentingReviewFor: Product?

    var filtered: [Product] {
        db.searchProducts(query: query)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { product in
                    NavigationLink(value: product) {
                        ProductRow(product: product)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            presentingReviewFor = product
                        } label: {
                            Label("Review", systemImage: "square.and.pencil")
                        }
                        .tint(.blue)

                        Button {
                            db.toggleLike(product)
                        } label: {
                            Label(db.isLiked(product, by: db.currentAccount) ? "Unlike" : "Like", systemImage: db.isLiked(product, by: db.currentAccount) ? "heart.slash" : "heart")
                        }
                        .tint(.pink)
                    }
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search skincare"))
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .sheet(item: $presentingReviewFor) { product in
                AddReviewSheet(product: product)
            }
        }
    }
}

private struct ProductRow: View {
    @EnvironmentObject private var db: MockDatabase
    let product: Product

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [.blue.opacity(0.15), .purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "leaf")
                        .foregroundStyle(.green)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                Text("\(product.brand) • \(product.category)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text(String(format: "%.1f", db.averageRating(for: product)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                db.toggleLike(product)
            } label: {
                Image(systemName: db.isLiked(product, by: db.currentAccount) ? "heart.fill" : "heart")
                    .foregroundStyle(.pink)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

private struct ProductDetailView: View {
    @EnvironmentObject private var db: MockDatabase
    let product: Product
    @State private var showingAddReview = false

    var body: some View {
        List {
            Section("About") {
                Text(product.description)
            }

            Section("Reviews") {
                let reviews = db.reviews(for: product)
                if reviews.isEmpty {
                    Text("No reviews yet. Be the first to add one!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reviews) { review in
                        ReviewRow(review: review)
                    }
                }
            }
        }
        .navigationTitle(product.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddReview = true
                } label: {
                    Label("Add Review", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewSheet(product: product)
        }
    }
}

private struct ReviewRow: View {
    @EnvironmentObject private var db: MockDatabase
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "person.circle")
                Text(authorName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                    Text("\(review.rating)")
                }
                .font(.subheadline)
            }
            Text(review.text)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if review.authorId == db.currentAccount.id {
                Button(role: .destructive) {
                    _ = db.deleteReviewIfAuthorMatchesCurrentUsername(for: productForSwipeContext, review: review)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private var productForSwipeContext: Product {
        // Resolve the product for this review; fall back to a dummy name if missing
        if let prod = db.products.first(where: { $0.id == review.productId }) {
            return prod
        }
        // Fallback product in unlikely case of mismatch; id must match review.productId to pass guard in delete method
        return Product(id: review.productId, name: "Unknown", brand: "", category: "", description: "")
    }

    private var authorName: String {
        if review.authorId == db.currentAccount.id {
            return db.currentAccount.displayName
        }
        return "User"
    }
}

private struct AddReviewSheet: View {
    @EnvironmentObject private var db: MockDatabase
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 5
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Rating") {
                    Stepper(value: $rating, in: 1...5) {
                        HStack {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                            Text("\(rating)")
                        }
                    }
                }
                Section("Review") {
                    TextEditor(text: $text)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Add Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        db.addReview(for: product, rating: rating, text: text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    DiscoverView()
        .environmentObject(MockDatabase.shared)
}
