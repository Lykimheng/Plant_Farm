//
//  PopularSection.swift
//  PP
//
//  Created by Ly Kimheng on 10/1/26.
//

import SwiftUI

struct PopularSection: View {
    @EnvironmentObject var catalog: PlantsModel

    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 171/255, green: 251/255, blue: 255/255, opacity: 1.0), .white]), startPoint: .top, endPoint: .bottom)
            VStack{
                HStack{
                    Text("Popular Plants")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.leading, 16)
                  
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(catalog.popularPlants) { plant in
                                NavigationLink(value: plant) {
                                    PopularCard(plant: plant)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                         .padding(.leading ,20)
                }
            }
        }
        .frame(height: 250)
    }
}

#Preview {
    PopularSection()
        .environmentObject(PlantsModel())
}
