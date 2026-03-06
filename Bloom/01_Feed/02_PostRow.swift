import SwiftUI

struct PostRow: View {
    let post: Post
    var onLike: () -> Void
    var onComment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(post.author)
                    .font(.headline)
                Spacer()
                Button(action: onLike) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(post.isLiked ? .red : .secondary)
                }
                Button(action: onComment) {
                    Image(systemName: "text.bubble")
                }
            }
            Text(post.text)
                .font(.body)
        }
        .padding(.vertical, 8)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PostRow(post: Post(id: UUID(), author: "Alice", text: "Hello Bloom!", isLiked: false), onLike: {}, onComment: {})
        .padding()
}
