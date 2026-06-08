//
//  TypePlants.swift
//  PP
//
//  Created by Ly Kimheng on 16/1/26.
//

import SwiftUI

struct TypePlants: View {
    var title: String
    var isExpanded: Bool = false
    var onToggle: () -> Void = { }
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .bold()

            Spacer()

            Button{
                onToggle()
            }
                label: {
                    Text(isExpanded ? "See Less" : "See More")
                    Image(systemName: isExpanded ? Constants.seeLessIcon : Constants.seeMoreIcon)
            }
                .foregroundStyle(Color.gray)

        }
        .padding(.horizontal, 16)
        }
}
