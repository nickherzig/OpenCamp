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
    @State private var errorText = ""
    
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(){
                Image("LogoBlack")
                    .resizable()
                    .frame(width: 250.0, height: 250.0)
                Text("OpenCamp")
                    .foregroundColor(.black)
                    .font(.system(size:50, weight: .bold))
                    .padding()
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
                        errorText = "Fields cannot be empty"
                        return
                    }
                    authModel.signIn(email: email, password: password)
                    errorText = authModel.getErrorMessage()
                } label: {
                    Text("Log In")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(width: 100, height: 20)
                .padding()
                Text(errorText)
                    .frame(alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size:11))
                    .multilineTextAlignment(.center)

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
