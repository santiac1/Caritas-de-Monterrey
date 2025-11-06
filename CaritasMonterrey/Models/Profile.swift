//
//  ProfileModel.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//
//  Este archivo define el Modelo de Datos para el Perfil de Usuario.
//

import Foundation

/// El modelo de datos principal para el perfil de un usuario.
/// Esta estructura agrupa toda la información del usuario.
/// En el futuro, se cargará y guardará en la base de datos.
struct UserProfile {
    var nombrePublico: String
    var nombre: String
    var apellido: String
    var telefono: String
    var direccion: String
    var fechaNacimiento: Date
    
    /// Un inicializador vacío para crear un perfil nuevo
    init(nombrePublico: String = "",
         nombre: String = "",
         apellido: String = "",
         telefono: String = "",
         direccion: String = "",
         fechaNacimiento: Date = Date()) {
        
        self.nombrePublico = nombrePublico
        self.nombre = nombre
        self.apellido = apellido
        self.telefono = telefono
        self.direccion = direccion
        self.fechaNacimiento = fechaNacimiento
    }
}

// MARK: - Datos de Muestra (Mock Data)

// (Opcional) Si quisieras un perfil de muestra para Previews
// podrías añadirlo aquí:
struct ProfileData {
    static let mockProfile = UserProfile(
        nombrePublico: "VicValero",
        nombre: "Victor",
        apellido: "Valero",
        telefono: "8112345678",
        direccion: "Av. Siempre Viva 123"
    )
}
