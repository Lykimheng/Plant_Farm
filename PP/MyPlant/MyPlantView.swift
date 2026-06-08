//
//  MyPlantView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import SwiftUI

struct MyPlantView: View {
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.yellow, .purple, .green]), startPoint: .top, endPoint: .bottom)
            Text("My Plant")
                .font(.largeTitle)
                .bold()
        }
        .ignoresSafeArea()
//        VStack{
//            Text("My Plant")
//                .font(.largeTitle)
//                .bold()
//            
//            Spacer()
//            HStack{
//                Text("Water your plants"
//                    .font(.title)
//                Spacer()
//            }
//            Spacer()
//            HStack(spacing: 20){
//                Button("Livivng Room"){
//                }
//                .foregroundStyle(Color.black)
//                Button("Bedroom"){
//                }
//                .foregroundStyle(Color.black)
//                Button("Office"){
//                }
//                .foregroundStyle(Color.black)
//                Button("Kitchen"){
//                }
//                .foregroundStyle(Color.black)
//                Button("Fish Tank"){
//                }
//                .foregroundStyle(Color.black)
//            }
//            
//            Spacer()
//
//        }
//        .preferredColorScheme(.light)
    }
}


#Preview {
    MyPlantView()
}
