//
//  ContentView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/14/23.
//

import SwiftUI
import Firebase

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    
    @EnvironmentObject var authModel: AuthViewModel

    var body: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(){
                Text("Open Camp")
                    .foregroundColor(.white)
                    .font(.system(size:40, weight: .bold))
                    .offset(y: -100)
                Text("Email")
                    .frame(width: 350, alignment: .leading)
                    .foregroundColor(.white)
                    .font(.system(size:20))
                TextField("", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                Text("Password")
                    .frame(width: 350, alignment: .leading)
                    .foregroundColor(.white)
                    .font(.system(size:20))
                SecureField("", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                Text("Confirm Password")
                    .frame(width: 350, alignment: .leading)
                    .foregroundColor(.white)
                    .font(.system(size:20))
                SecureField("", text: $passwordConfirm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    guard !email.isEmpty, !password.isEmpty, !passwordConfirm.isEmpty, password == passwordConfirm else {
                        return
                    }
                    authModel.register(email: email, password: password)
                } label: {
                    Text("Sign up")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(width: 100, height: 20)
                .padding()
                NavigationLink(destination: LoginView()){
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundColor(.white)
                }
                .offset(y: 50)
            }
            .frame(width: 350)
        }
    }
}


struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
