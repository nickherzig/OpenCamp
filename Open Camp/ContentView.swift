//
//  ContentView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/14/23.
//

import SwiftUI

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
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
                    .foregroundColor(.white)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Password")
                    .frame(width: 350, alignment: .leading)
                    .foregroundColor(.white)
                    .font(.system(size:20))
                SecureField("", text: $email)
                    .foregroundColor(.white)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    //sign up
                } label: {
                    Text("Sign up")
                        .bold()
                        .frame(width: 200, height: 40)
                        
                }

            }
            .frame(width: 350)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
