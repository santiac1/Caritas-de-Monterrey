//
//  AppConstants.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct AppColors {
    static let primaryCyan = Color("PrimaryCyan")   // define en Assets
    static let secondaryBlue = Color("SecondaryBlue")
    static let lightGray = Color("LightGray")
    static let gray = Color("Gray")
    static let magenta = Color("Magenta")
    static let orange = Color("Orange")
}

struct AppFonts {
    static func roundedFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }
}
