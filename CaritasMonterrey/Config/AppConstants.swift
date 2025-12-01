//
//  AppConstants.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI

struct AppColors {
    static let primaryCyan = Color("PrimaryCyan")
    static let secondaryBlue = Color("SecondaryBlue")
    static let lightGrayCaritas = Color("LightGrayCaritas")
    static let grayCaritas = Color("GrayCaritas")
    static let magentaCaritas = Color("MagentaCaritas")
    static let orangeCaritas = Color("OrangeCaritas")
}

struct AppFonts {
    static func roundedFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }
}
