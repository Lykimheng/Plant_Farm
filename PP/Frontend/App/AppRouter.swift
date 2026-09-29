//
//  AppRouter.swift
//  PP
//
//  Created by Ly Kimheng on 7/8/26.
//

import SwiftUI
import Combine

enum AppTab: Hashable, CaseIterable {
    case home, cart, scan, myPlants, profile

    var title: LocalizedStringResource {
        switch self {
        case .home:     return "Home"
        case .cart:     return "Cart"
        case .scan:     return "Scan"
        case .myPlants: return "My Plants"
        case .profile:  return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home:     return Icons.home
        case .cart:     return Icons.cart
        case .scan:     return Icons.scan
        case .myPlants: return Icons.myPlants
        case .profile:  return Icons.profile
        }
    }
}

enum CartRoute: Hashable {
    case checkout
    case orderPlaced(OrderModel)
    case orderDetail(OrderModel)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var cartPath: [CartRoute] = []
    
    func returnToShop() {
        cartPath.removeAll()
        selectedTab = .home
    }

    func push(_ route: CartRoute) {
        cartPath.append(route)
    }
}
