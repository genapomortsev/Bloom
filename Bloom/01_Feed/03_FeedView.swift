//
//  FeedView.swift
//  Bloom
//
//  Created by Гена Поморцев on 03/03/2026.
//
import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()

    var body: some View {
        NavigationStack {
            List(vm.posts) { post in
                PostRow(post: post,
                        onLike: { vm.toggleLike(post) },
                        onComment: { vm.openComments(post) })
            }
            .navigationTitle("Feed")
            .task { await vm.loadInitial() }
            .refreshable { await vm.refresh() }
        }
    }
}
