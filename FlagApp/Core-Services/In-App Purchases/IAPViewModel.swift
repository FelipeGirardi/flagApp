//
//  IAPViewModel.swift
//  FlagApp
//
//  Created by Felipe Girardi on 25/11/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import Foundation
import SwiftUI

public final class IAPViewModel: ObservableObject {
    @ObservedObject var userManager: UserManager
    var iapManager: IAPManager
    @Binding var showIAPScreen: Bool

    init(userManager: UserManager, iapManager: IAPManager, showIAPScreen: Binding<Bool>) {
        self.userManager = userManager
        self.iapManager = iapManager
        self._showIAPScreen = showIAPScreen
    }
}
