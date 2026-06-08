//
//  SuccessView.swift
//  PP
//
//  Created by Ly Kimheng on 30/4/26.
//

import SwiftUI

struct SuccessView: View {
    @State private var progress: CGFloat = 0
    @State private var circleScale: CGFloat = 0
    @State private var backHome = false
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                ZStack {
                    // Circle background
                    Circle()
                        .fill(Color(red: 32/255, green: 169/255, blue: 172/255))
                        .frame(width: 100, height: 100)
                        .scaleEffect(circleScale)
                    
                    // Animated checkmark stroke
                    CheckmarkShape()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                        .frame(width: 48, height: 54)
                }
                .onAppear {
                    // Circle pops in first
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        circleScale = 1
                    }
                    // Then checkmark draws itself
                    withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                        progress = 1
                    }
                }
                Text("Payment Successful")
                    .font(.title.bold())
                    .foregroundStyle(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255))
                
                Spacer()
                
                Button("Back to home"){
                    backHome = true
                }
                .padding()
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(Color(.sRGB, red: 32/255, green: 169/255, blue: 172/255, opacity: 1.0))
                .cornerRadius(10)
                
                Spacer()
            }
            .preferredColorScheme(.light)
            .navigationDestination(isPresented: $backHome){
                HomeView()
                    .toolbar(.hidden)
            }
        }
    }
}


struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.72))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.28))
        return path
    }
}

#Preview {
    SuccessView()
}
