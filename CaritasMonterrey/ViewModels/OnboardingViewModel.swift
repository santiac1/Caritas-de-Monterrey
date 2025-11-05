//
//  OnboardingViewModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation
import Combine  
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var shouldShowOnboarding: Bool = true
    func finish() { shouldShowOnboarding = false }
}
