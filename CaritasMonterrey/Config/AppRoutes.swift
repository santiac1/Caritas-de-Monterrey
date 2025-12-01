//
//  AppConstants.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation

enum AuthRoute: Hashable {
    case login
    case signup
    case mainRegistro 
}

enum AppRoute: Hashable {
    case map
    case myDonations
    case notifications
    case profile
    case settings
    case aboutCaritas
    case campaignDetail(Campaign)
    case donationDetail(Donation)
    case adminDonationDetail(Donation)
    case bazaarForm(Location?)
    
    case donateAction
}
