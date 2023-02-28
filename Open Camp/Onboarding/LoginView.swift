//
//  LogIn.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/22/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
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
                Button {
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    authModel.signIn(email: email, password: password)
                } label: {
                    Text("Log In")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(width: 100, height: 20)
                .padding()

            }
            .frame(width: 350)
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
