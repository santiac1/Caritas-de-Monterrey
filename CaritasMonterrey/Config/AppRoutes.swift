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
}

// Rutas para la navegación principal
enum AppRoute: Hashable {
    case map
    case myDonations
    case notifications
    case profile
    case settings // ✅ Nueva ruta agregada
    
    // Caso especial: Acción
    case donateAction
}
