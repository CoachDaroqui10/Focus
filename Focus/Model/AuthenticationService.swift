//
//  AuthenticationService.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 09/07/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationService
{
    static let sharedInstance = AuthenticationService()
    typealias CompleteHandler = (Error?) -> Void
    
    func loginUser(email: String, password: String, onComplete: @escaping
        CompleteHandler)
    {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code)
            {
                print("Ha habido un error de autenticación del usuario: \(errorCode)")
                onComplete(error)
                return
            }
            
            print ("Usuario autentificado")
            onComplete(nil)
        }
    }
    
    func registerUser(email: String, password: String, onComplete: @escaping
        CompleteHandler)
    {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code)
            {
                print("Ha habido un error creando el usuario: \(errorCode)")
                onComplete(error)
                return
            }
            
            print("Usuario registrado")
            DatabaseService.sharedInstance.saveUser(userId: Auth.auth().currentUser!.uid, email: email)
            onComplete(nil)
        }
    }
    
    func logout()
    {
        do
        {
            try Auth.auth().signOut()
            print("Log out completado")
        }
        catch
        {
            print("Error en logout")
        }
    }
}
