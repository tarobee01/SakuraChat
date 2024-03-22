import Foundation
import FirebaseAuth
import FirebaseFirestore

//Authenticationの認証、ユーザーの消去を管理
class AuthService {
    let auth = Auth.auth()
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func deleteUser() async throws {
        guard let user = auth.currentUser else { return }
        try await user.delete()
    }
}
