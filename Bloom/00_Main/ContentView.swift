//
//  ContentView.swift
//  Bloom
//
//  Created by Гена Поморцев on 03/03/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab = 0
    var body: some View {
        Group {
            if auth.isLoggedIn {
                TabView(selection: $selectedTab) {
                    Tab("Feed", systemImage: "newspaper", value: 0) {
                        FeedView()
                    }

                    Tab("Discover", systemImage: "magnifyingglass", value: 1) {
                        DiscoverView()
                    }
                    
                    Tab("Add", systemImage: "plus.app", value: 2) {
                        AddView()
                    }
                    
                    Tab("My Products", systemImage: "folder", value: 3) {
                        MyProductsView()
                    }

                    Tab("Profile", systemImage: "person.crop.circle.fill", value: 4) {
                        AccountView()
                    }
                }
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(MockDatabase.shared)
}

