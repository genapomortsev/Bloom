import SwiftUI

struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let rating: Double
    let isFavorite: Bool
}

private let sampleFavoriteProducts: [Product] = [
    Product(name: "Hydrating Cleanser", category: "Cleanser", rating: 4.7, isFavorite: true),
    Product(name: "Vitamin C Serum", category: "Serum", rating: 4.6, isFavorite: true),
    Product(name: "Niacinamide 10%", category: "Serum", rating: 4.5, isFavorite: true),
    Product(name: "Daily Moisturizer", category: "Moisturizer", rating: 4.8, isFavorite: true),
    Product(name: "SPF 50 Sunscreen", category: "Sunscreen", rating: 4.9, isFavorite: true),
    Product(name: "Retinol 0.5%", category: "Treatment", rating: 4.4, isFavorite: true)
]

struct MyProductsView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(sampleFavoriteProducts) { product in
                        ProductCard(product: product)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Favorites")
            .background(Color(.systemGroupedBackground))
        }
    }
}

private struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 110)

                Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(.red)
                    .padding(8)
            }

            Text(product.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            HStack(spacing: 6) {
                Text(product.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", product.rating))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.05))
        )
    }
}

#Preview {
    MyProductsView()
}
