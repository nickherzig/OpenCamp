//
//  AccountView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack{
                Text("Account View")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                
                Spacer()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
