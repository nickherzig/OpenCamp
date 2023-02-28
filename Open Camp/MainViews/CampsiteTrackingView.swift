//
//  CampsiteTrackingView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct CampsiteTrackingView: View {
    @State private var trackers = []
    
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack{
                Text("Currently Tracking")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                
                Spacer()
            }
        }
    }
}

struct CampsiteTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        CampsiteTrackingView()
    }
}
