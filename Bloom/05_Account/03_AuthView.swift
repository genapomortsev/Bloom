import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var mode: Mode = .signIn
    @State private var username: String = ""
    @State private var password: String = ""

    enum Mode { case signIn, create }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(mode == .signIn ? "Welcome back" : "Create your account")
                    .font(.largeTitle.bold())

                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password (demo only)", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button(mode == .signIn ? "Sign In" : "Create Account") {
                    auth.username = username
                    auth.password = password
                    if mode == .signIn {
                        auth.signIn()
                    } else {
                        auth.createAccount()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button(mode == .signIn ? "Need an account? Create one" : "Already have an account? Sign in") {
                    withAnimation { mode = (mode == .signIn ? .create : .signIn) }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
