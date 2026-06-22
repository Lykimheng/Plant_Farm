//
//  ScrollOffsetKey.swift
//  PP
//
//  Created by Ly Kimheng on 25/12/25.
//

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
