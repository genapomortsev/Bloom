import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var tempFullName: String = ""
    @State private var tempBio: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayName)
                                .font(.headline)
                            Text("@\(auth.username)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Edit Details") {
                    TextField("Full name", text: $tempFullName)
                        .textContentType(.name)
                    TextField("Bio", text: $tempBio, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                if !auth.isLoggedIn {
                    Section {
                        Text("Sign in to edit your profile.")
                            .foregroundStyle(.secondary)
                    }
                }

                if auth.isLoggedIn {
                    Section {
                        Button(role: .destructive) {
                            auth.signOut()
                        } label: {
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!auth.isLoggedIn || !hasChanges)
                }
            }
            .onAppear(perform: loadFromAuth)
        }
    }

    private var displayName: String {
        let currentFullName: String = auth.fullName
        let currentUsername: String = auth.username
        if tempFullName.isEmpty {
            return currentFullName.isEmpty ? currentUsername : currentFullName
        } else {
            return tempFullName
        }
    }

    private var hasChanges: Bool {
        let currentFullName: String = auth.fullName
        let currentBio: String = auth.bio
        return tempFullName != currentFullName || tempBio != currentBio
    }

    private func loadFromAuth() {
        tempFullName = auth.fullName
        tempBio = auth.bio
    }

    private func save() {
        auth.fullName = tempFullName
        auth.bio = tempBio
        auth.saveProfile()
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthViewModel())
}
