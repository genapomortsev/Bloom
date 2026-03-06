import Combine
import Foundation
import SwiftUI

struct Post: Identifiable, Hashable {
    let id: UUID
    var author: String
    var text: String
    var isLiked: Bool
}

@MainActor
final class FeedViewModel: ObservableObject {
    
    @Published private(set) var posts: [Post] = []

    init() {}

    func loadInitial() async {
        posts = [
            Post(id: UUID(), author: "Alice", text: "Hello Bloom!", isLiked: false),
            Post(id: UUID(), author: "Bob", text: "What a great day 🌤️", isLiked: true)
        ]
    }

    func refresh() async {
        if !posts.isEmpty {
            posts[0].isLiked.toggle()
        }
    }

    func toggleLike(_ post: Post) {
        guard let idx = posts.firstIndex(of: post) else { return }
        posts[idx].isLiked.toggle()
    }

    func openComments(_ post: Post) {
        // Placeholder: hook up navigation or sheet presentation in the future
        print("Open comments for post: \(post.id)")
    }
}
