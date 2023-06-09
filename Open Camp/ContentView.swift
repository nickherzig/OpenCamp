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
    @Published var errorMessage = ""
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func register(email : String, password: String, callbackHandler : @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                self?.errorMessage = error!.localizedDescription
                callbackHandler()
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
                self?.sendEmailVerification()
            }
        }
    }
    
    func signIn(email : String, password: String, callbackHandler : @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                self?.errorMessage = error!.localizedDescription
                callbackHandler()
                return
            }
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
        
    }
    
    func sendEmailVerification(){
            if self.auth.currentUser != nil && !self.auth.currentUser!.isEmailVerified {
                self.auth.currentUser?.sendEmailVerification(completion: { (error) in
                    if error != nil {
                        print("Unable to send email verification")
                    }
                    else{
                        print("Email verification sent")
                    }
                    })
                }
            else {
                print("Unable to send email verification")
            }
    }
    
    func validateSignUpInfo(email : String, password : String, passwordConfirm : String) -> String{
        let validPass = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$")
        if email.isEmpty || password.isEmpty || passwordConfirm.isEmpty {
             return "Fields cannot be empty"
        }
        else if password != passwordConfirm {
            return  "Passwords must match"
        }
        else if !validPass.evaluate(with: password){
            return "Password must have at least 8 characters, 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number"
        }
        return ""
    }
    
    func getErrorMessage() -> String {
        return self.errorMessage
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
