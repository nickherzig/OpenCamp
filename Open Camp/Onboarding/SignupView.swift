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
                    
                Group{
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
                }
                
                Button {
                    errorText = authModel.validateSignUpInfo(email: email, password: password, passwordConfirm: passwordConfirm)
                    if errorText.isEmpty{
                        authModel.register(email: email, password: password) {
                            errorText = authModel.getErrorMessage()
                        }
                        
                    }
                    
                } label: {
                    Text("Sign up")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(width: 100, height: 20)
                .padding()
                Text(errorText)
                    .frame(alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size:11))
                    .multilineTextAlignment(.center)
                NavigationLink(destination: LoginView()){
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundColor(.white)
                }
                
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
