//
//  ContentView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI
import Firebase

class AuthViewModel: ObservableObject{
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func register(email : String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signIn(email : String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authModel: AuthViewModel
    var body: some View {
        NavigationView {
            if authModel.signedIn {
                MainView()
            }
            else{
                SignupView()
            }
            
        }.onAppear{
            authModel.signedIn = authModel.isSignedIn
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
