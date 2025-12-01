//
//  AppConstants.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Foundation

// Rutas para el flujo de autenticación (fuera de la app principal)
enum AuthRoute: Hashable {
    case login
    case signup
    case mainRegistro // ✅ Nueva ruta para la pantalla principal de registro
}

// Rutas para la navegación principal
enum AppRoute: Hashable {
    case map
    case myDonations
    case notifications
    case profile
    case settings // ✅ Nueva ruta agregada
    case campaignDetail(Campaign) // ✅ Detalle de campaña
    case donationDetail(Donation) // ✅ Detalle de donación
    case adminDonationDetail(Donation) // ✅ Detalle de solicitud (Admin)
    
    // Caso especial: Acción
    case donateAction
}
