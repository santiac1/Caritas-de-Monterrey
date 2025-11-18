//
//  FontsHelper.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI
import Combine

enum FontsHelper {
    static func appFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }
    
    static func gotham(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .ultraLight:
            fontName = "Gotham-XLight"
        case .thin:
            fontName = "Gotham-Thin"
        case .light:
            fontName = "Gotham-Light"
        case .regular:
            fontName = "Gotham-Book"
        case .medium:
            fontName = "Gotham-Medium"
        case .semibold, .bold:
            fontName = "Gotham-Bold"
        case .heavy, .black:
            fontName = "Gotham-Black"
        default:
            fontName = "Gotham-Book"
        }
        return Font.custom(fontName, size: size)
    }
}
