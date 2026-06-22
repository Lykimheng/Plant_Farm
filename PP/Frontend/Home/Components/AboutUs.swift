//
//  AboutUs.swift
//  PP
//
//  Created by Ly Kimheng on 22/1/26.
//

import SwiftUI

struct AboutUs: View {
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 171/255, green: 251/255, blue: 255/255, opacity: 1.0), .white]), startPoint: .top, endPoint: .bottom)
            VStack{
                HStack{
                    Text("We are here to help you")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button{
                    }
                        label: {
                            Text("Explore more")

                            Image(systemName: Constants.seeMoreIcon)
                    }
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal, )
                Spacer()
                Image("photo4")
                    .imageScale(.large)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 250)
    }
}

#Preview {
    AboutUs()
}
