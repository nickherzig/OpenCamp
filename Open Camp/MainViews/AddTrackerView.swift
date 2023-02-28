//
//  AddTrackerView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct AddTrackerView: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack{
                Text("Add Campsite")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                
                Spacer()
            }
        }
    }
}

struct AddTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        AddTrackerView()
    }
}
