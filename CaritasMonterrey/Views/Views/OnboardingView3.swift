//
//  OnboardingView1.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import SwiftUI
import Combine  

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Cáritas Monterrey")
                .font(.largeTitle).bold()
            Text("Misión, visión y valores")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Comenzar") { viewModel.finish() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
