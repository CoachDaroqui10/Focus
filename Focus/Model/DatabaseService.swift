//
//  DatabaseService.swift
//  Focus
//
//  Created by Pepe Daroqui Plaza on 11/07/2019.
//  Copyright © 2019 Pepe Daroqui Plaza. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class DatabaseService
{
    static let sharedInstance = DatabaseService()
    typealias CompleteHandler = (Error?) -> Void
    
    func saveUser(userId: String, email: String)
    {
        let ref = Database.database().reference()
        
        ref.child("users").child(userId).setValue(["email" : email])
        print("Usuario almacenado en la base de datos")
    }
    
    func checkUsername(username: String, onComplete: @escaping (Bool) -> Void)
    {
        Database.database().reference().child("users")
            .queryOrdered(byChild: "username")
            .queryEqual(toValue: username)
            .observeSingleEvent(of: .value) { snapshot in
                
                if let dic = snapshot.value as? Dictionary<String, Any>
                {
                    let userKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                    print("Usuario no disponible")
                    onComplete(false)
                }
                else
                {
                    print("Usuario disponible")
                    onComplete(true)
                }
        }
    }
    
    func registerUserData(userID: String, name: String, lastName: String, username: String)
    {
        let ref = Database.database().reference()
        
        ref.child("users/\(userID)/name").setValue(name)
        ref.child("users/\(userID)/lastName").setValue(lastName)
        ref.child("users/\(userID)/username").setValue(username)
        ref.child("users/\(userID)/description").setValue("")
        ref.child("users/\(userID)/imageUrl").setValue("")
        print("Nombre y apellido/s almacenados en la base de datos")
    }
    
    func recieveUserData(onComplete: @escaping (User?) -> Void)
    {
        let ref = Database.database().reference()
        var user = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
        
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with:
            { (snapshot) in
                // Get user values
                let userDic = snapshot.value as? NSDictionary
                
                user = User(dictionary: userDic as! [String : Any])!
                
                onComplete(user)
        })
        { (error) in
            print(error.localizedDescription)
            onComplete(nil)
            return
        }
    }
    
    func recieveAnotherUserData(user: User, onComplete: @escaping (User?) -> Void)
    {
        Database.database().reference().child("users")
            .queryOrdered(byChild: "username")
            .queryEqual(toValue: user.username)
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Obtener el nodo llave
                let userKey = (snapshot.children.allObjects.first as! DataSnapshot).key

                var user = User(dictionary: ["name": "", "lastName" : "", "username" : "", "description": "", "imageUrl": ""])!
                
                Database.database().reference(withPath: "users/\(userKey)").observeSingleEvent(of: .value, with:
                    { (snapshot) in
                        // Get user values
                        let userDic = snapshot.value as? NSDictionary
                        
                        user = User(dictionary: userDic as! [String : Any])!
                        
                        onComplete(user)
                })
                { (error) in
                    print(error.localizedDescription)
                    onComplete(nil)
                    return
                }
        }
    }
    
    func updateUserDataNoPic(user: User)
    {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        ref.child("users/\(userID!)/name").setValue(user.name)
        ref.child("users/\(userID!)/lastName").setValue(user.lastName)
        ref.child("users/\(userID!)/username").setValue(user.username)
        ref.child("users/\(userID!)/description").setValue(user.description)
        ref.child("users/\(userID!)/imageUrl").setValue("")
        print("Datos actualizados en la base de datos")
    }
    
    func updateUserDataWithPic(user: User, picture: Data)
    {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        //1. Subir la imagen storage
        let imagename = "\(user.name)-\(UUID().uuidString).png"
        
        //2. Crear metadata de la imagen
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        //3 Obtener acceso a storage con la url
        let refStorage = Storage.storage()
            .reference(forURL: "gs://focus-48642.appspot.com")
            .child("userProfile/\(imagename)")
        
        //4. Subir datos de la imagen
        refStorage.putData(picture, metadata: metadata) { metadata, error in
            if let error = error
            {
                print("Error subiendo la foto: \(error)")
                //onComplete(error)
                return
            }
            
            //5. Si la imagen se sube, obtener url de descarga
            refStorage.downloadURL { url, error in
                
                if let error = error
                {
                    print("Error obteniendo url de descarga: \(error.localizedDescription)")
                    //onComplete(error)
                    return
                }
                
                ref.child("users/\(userID!)/name").setValue(user.name)
                ref.child("users/\(userID!)/lastName").setValue(user.lastName)
                ref.child("users/\(userID!)/username").setValue(user.username)
                ref.child("users/\(userID!)/description").setValue(user.description)
                ref.child("users/\(userID!)/imageUrl").setValue(url?.absoluteString)
                print("Datos e imagen actualizados en la base de datos")
            }
        }
    }
    
    func downloadUserImage(user: User, onComplete: @escaping (UIImage?) -> Void)
    {
        if user.imageUrl != ""
        {
            let httpsReference = Storage.storage().reference(forURL: user.imageUrl)
            
            httpsReference.getData(maxSize: 100 * 1024 * 1024) { data, error in
                
                if let error = error {
                    
                    onComplete(nil)
                } else {
                    
                    let image = UIImage(data: data!)
                    onComplete(image)
                }
            }
        }
        else
        {
            onComplete(nil)
        }
    }
    
    func createGroup(name: String, picture: Data, onComplete: @escaping (Error?) -> Void)
    {
        //1. Subir la imagen storage
        let imagename = "\(name)-\(UUID().uuidString).png"
        
        //2. Crear metadata de la imagen
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        //3 Obtener acceso a storage con la url
        let ref = Storage.storage()
            .reference(forURL: "gs://focus-48642.appspot.com")
            .child("groupsImages/\(imagename)")
        
        //4. Subir datos de la imagen
        ref.putData(picture, metadata: metadata) { metadata, error in
            if let error = error
            {
                print("Error subiendo la foto: \(error)")
                onComplete(error)
                return
            }
            
            //5. Si la imagen se sube, obtener url de descarga
            ref.downloadURL { url, error in
                
                if let error = error
                {
                    print("Error obteniendo url de descarga: \(error.localizedDescription)")
                    onComplete(error)
                    return
                }
                
                //6. Crear diccionario con los datos para la base de datos
                let data: Dictionary<String, Any> = ["name": name, "imageURL" : url?.absoluteString as Any]
                
                //7. Crear nuevo nodo de la base de datos con la información del diccionario
                Database.database().reference(withPath: "groups").childByAutoId().setValue(data)
                print("Almacenada imagen en BD")
                
                //Insertar usuario creador
                //PASO 1: Insertar el usuario en el grupo
                //1. Encontrarla llave del grupo a través del hijo "name"
                Database.database().reference().child("groups")
                    .queryOrdered(byChild: "name")
                    .queryEqual(toValue: name)
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //2. Obtener el nodo llave
                        let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                        
                        //3. Leer valores del grupo seleccionado
                        Database.database().reference(withPath: "groups/\(groupKey)/users")
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                let userId = Auth.auth().currentUser!.uid
                                var userArray = [String]()
                                userArray.append(userId)
                                snapshot.ref.setValue(userArray)
                                
                                //PASO 2: Insertar el grupo en el nodo del usuario
                                //4. Recuperar el nodo del usuario
                                Database.database().reference(withPath: "users/\(userId)/groups")
                                    .observeSingleEvent(of: .value) { snapshot in
                                        
                                        //5. Recuperar grupos del usuario
                                        var groupsArray = [String]()
                                        if let groups = snapshot.value as? [String]
                                        {
                                            groupsArray = groups
                                        }
                                        
                                        //6. Añadir el grupo nuevo
                                        groupsArray.append(groupKey)
                                        snapshot.ref.setValue(groupsArray)
                                }
                        }
                }
                //8. Finalizar la función sin errores
                onComplete(nil)
            }
        }
    }
    
    func changeGroupName(group: Group, name: String)
    {
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Obtener el nodo llave
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                Database.database().reference(withPath: "groups/\(groupKey)/name").setValue(name)
        }
    }
    
    func joinGroup(group: Group, onComplete: @escaping (Error?) -> Void)
    {
        //PASO 1: Insertar el usuario en el grupo
        //1. Encontrarla llave del grupo a través del hijo "name"
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Obtener el nodo llave
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                //3. Leer valores del grupo seleccionado
                Database.database().reference(withPath: "groups/\(groupKey)/users")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //4. Los usuarios se almacenan como array, recogerlos para añadir el nuevo
                        var userArray = [String]()
                        if let users = snapshot.value as? [String]
                        {
                            userArray = users
                        }
                        
                        //5. Comprobar que el usuario no existe en el grupo
                        let userId = Auth.auth().currentUser!.uid
                        if userArray.contains(userId)
                        {
                            //Error personalizado
                            onComplete(DataBaseServiceError.userAlreadyInGroup)
                            return
                        }
                        
                        //6. Actualizar el nodo de grupos con el usuario nuevo
                        userArray.append(userId)
                        snapshot.ref.setValue(userArray)
                        
                        //PASO 2: Insertar el grupo en el nodo del usuario
                        //7. Recuperar el nodo del usuario
                        Database.database().reference(withPath: "users/\(userId)/groups")
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                //8. Recuperar grupos del usuario
                                var groupsArray = [String]()
                                if let groups = snapshot.value as? [String]
                                {
                                    groupsArray = groups
                                }
                                
                                //9. Añadir el grupo nuevo
                                groupsArray.append(groupKey)
                                snapshot.ref.setValue(groupsArray)
                                
                                //10. Finalizar
                                onComplete(nil)
                        }
                }
        }
    }
    
    func retrieveAllUserGroups(for userId: String, onComplete: @escaping ([Group]?) -> Void)
    {
        //1. Obtener los grupos del usuario en forma de array
        Database.database().reference(withPath: "users/\(userId)/groups")
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Comprobar errores
                guard let userGroups = snapshot.value as? [String] else
                {
                    onComplete(nil)
                    return
                }
                
                //3. Con el array de grupos, sincronizar las peticiones de cada grupo para obtener la información
                let semaphore = DispatchGroup()
                var groups = [Group]()
                
                userGroups.forEach { groupId in
                    
                    //4. Entrar en el bloque
                    semaphore.enter()
                    
                    //5. Recibir datos
                    Database.database().reference(withPath: "groups/\(groupId)")
                        .observeSingleEvent(of: .value) { snapshot in
                            
                            guard let dic = snapshot.value as? Dictionary<String, Any> else {
                                print("Dentro del guard")
                                semaphore.leave()
                                return
                            }
                            
                            //print(dic)
                            groups.append(Group(dictionary: dic)!)
                            
                            //6. Salir del bloque
                            semaphore.leave()
                    }
                }
                
                //7. Con todas las respuestas obtenidas, notificar
                semaphore.notify(queue: .main) {
                    print("Finalizadas todas las peticiones")
                    
                    //8. Devolver datos con onComplete
                    onComplete(groups)
                }
        }
    }
    
    func getDataForPost(onComplete: @escaping (String?) -> Void)
    {
        let userId = Auth.auth().currentUser!.uid
        var name = ""
        var lastname = ""
        
        Database.database().reference(withPath: "users/\(userId)/name")
        .observeSingleEvent(of: .value) { snapshot in
            
            name = snapshot.value as! String
            
            Database.database().reference(withPath: "users/\(userId)/lastName")
                .observeSingleEvent(of: .value) { snapshot in
                    
                    lastname = snapshot.value as! String
                    let fullName = "\(name) \(lastname)"
                    onComplete(fullName)
            }
        }
    }
    
    func createPost(fullname: String, group: Group, text: String) //, onComplete: @escaping ([Error]?) -> Void)
    {
        let userId = Auth.auth().currentUser!.uid
        
        //Añadir publicación a la base de datos
        let data: Dictionary<String, Any> = ["user": userId,"username":  fullname,"timestamp": NSDate().timeIntervalSince1970, "text": text, "image" : ""]
        
        let postId = Database.database().reference(withPath: "posts").childByAutoId()
        postId.setValue(data)
        let postKey = postId.key
        print("Publicación almacenada en BD: \(postId)")
        
        //Añadir publicación al grupo donde se ha publicado
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                //Leer las demás publicaciones
                Database.database().reference(withPath: "groups/\(groupKey)/posts")
                    .queryOrdered(byChild: "timestamp")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //Almacenar publicaciones como array
                        var postArray = [String]()
                        if let posts = snapshot.value as? [String]
                        {
                            postArray = posts
                        }
                        
                        postArray.append(postKey!)
                        snapshot.ref.setValue(postArray)
                        print("Publicacion en base de datos")
                }
        }
    }
    
    func createPostWithPic(fullname: String, group: Group, text: String, picture: Data)
    {
        //1. Subir la imagen storage
        let imagename = "\(NSDate().timeIntervalSince1970)-\(UUID().uuidString).png"
        
        //2. Crear metadata de la imagen
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        //3 Obtener acceso a storage con la url
        let ref = Storage.storage()
            .reference(forURL: "gs://focus-48642.appspot.com")
            .child("\(group.name)/\(Auth.auth().currentUser!.uid)/\(imagename)")
        
        //4. Subir datos de la imagen
        ref.putData(picture, metadata: metadata) { metadata, error in
            if let error = error
            {
                print("Error subiendo la foto del post: \(error)")
                //onComplete(error)
                return
            }
            
            //5. Si la imagen se sube, obtener url de descarga
            ref.downloadURL { url, error in
                
                if let error = error
                {
                    print("Error obteniendo url de descarga del post: \(error.localizedDescription)")
                    //onComplete(error)
                    return
                }
                
                let userId = Auth.auth().currentUser!.uid
                
                //Añadir publicación a la base de datos
                let data: Dictionary<String, Any> = ["user": userId,"username":  fullname,"timestamp": NSDate().timeIntervalSince1970, "text": text, "image" : url?.absoluteString as Any]
                
                let postId = Database.database().reference(withPath: "posts").childByAutoId()
                postId.setValue(data)
                let postKey = postId.key
                print("Publicación almacenada en BD: \(postId)")
                
                //Añadir publicación al grupo donde se ha publicado
                Database.database().reference().child("groups")
                    .queryOrdered(byChild: "name")
                    .queryEqual(toValue: group.name)
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                        
                        //Leer las demás publicaciones
                        Database.database().reference(withPath: "groups/\(groupKey)/posts")
                            .queryOrdered(byChild: "timestamp")
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                //Almacenar publicaciones como array
                                var postArray = [String]()
                                if let posts = snapshot.value as? [String]
                                {
                                    postArray = posts
                                }
                                
                                postArray.append(postKey!)
                                snapshot.ref.setValue(postArray)
                                print("Publicacion en base de datos")
                        }
                }
            }
        }
    }
    
    func searchUsers(onComplete: @escaping ([User]?) -> Void)
    {
        //1. Leer datos del nodo "Users" de la BD
        Database.database().reference(withPath: "users").observeSingleEvent(of: .value)
        { snapshot in
            
            //2. Crear array vacío
            var usersArray = [User]()
            
            //3. Cada hijo del snapshot/nodo, ID del user
            snapshot.children.forEach { user in
                
                //4. Obtener cada nodo hijo y convertirlo a [String:Any]
                guard let snapshot = user as? DataSnapshot,
                    let userDic = snapshot.value as? Dictionary<String, Any>
                    else
                {
                    //5. Notificar error de conversión
                    onComplete(nil)
                    return
                }
                
                //6. Convertir cada diccionario al modelo User usando el método init?
                usersArray.append(User(dictionary: userDic)!)
            }
            
            //7. Devolver el grupo usando onComplete
            onComplete(usersArray)
        }
    }
    
    func retrieveGroupPosts(group: Group, onComplete: @escaping ([Post]?) -> Void)
    {
        //1. Obtener los posts del grupo en forma de array
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                Database.database().reference(withPath: "groups/\(groupKey)/posts")
                    .observeSingleEvent(of: .value) { snapshot in
                       
                        //2. Comprobar errores
                        guard let groupPosts = snapshot.value as? [String] else
                        {
                            onComplete(nil)
                            return
                        }
                        
                        //3. Con el array de grupos, sincronizar las peticiones de cada grupo para obtener la información
                        let semaphore = DispatchGroup()
                        var posts = [Post]()
                        
                        groupPosts.forEach { postId in
                            
                            //4. Entrar en el bloque
                            semaphore.enter()
                            
                            //5. Recibir datos
                            Database.database().reference(withPath: "posts/\(postId)")
                                .queryOrdered(byChild: "timestamp")
                                .observeSingleEvent(of: .value) { snapshot in
                                    
                                    guard let dic = snapshot.value as? Dictionary<String, Any> else {
                                        print("Dentro del guard")
                                        semaphore.leave()
                                        return
                                    }
                                    
                                    //print(dic)
                                    posts.append(Post(dictionary: dic)!)
                                    
                                    //6. Salir del bloque
                                    semaphore.leave()
                            }
                        }
                        
                        //7. Con todas las respuestas obtenidas, notificar
                        semaphore.notify(queue: .main) {
                            print("Finalizadas todas las peticiones")
                            
                            //8. Devolver datos con onComplete
                            onComplete(posts)
                        }
                }
        }
    }
    
    func checkInviteUser(username: String, group: String, onComplete: @escaping (Error?) -> Void)
    {
        let data: Dictionary<String, Any> = ["username": username, "group": group, "timestamp" : NSDate().timeIntervalSince1970]
        
        //COMPROBAR QUE EL USUARIO NO HA SIDO INVITADO AL GRUPO
        //Leer datos del nodo "Invites" de la BD
        Database.database().reference(withPath: "invites").observeSingleEvent(of: .value)
        { snapshot in
            
            //Crear array vacío
            var invitesArray = [Invite]()
            
            //Cada hijo del snapshot/nodo, ID del invite
            snapshot.children.forEach { invite in
                
                //4. Obtener cada nodo hijo y convertirlo a [String:Any]
                guard let snapshot = invite as? DataSnapshot,
                    let inviteDic = snapshot.value as? Dictionary<String, Any>
                    else
                {
                    //Notificar error de conversión
                    print("Error de conversión de la invitación!")
                    return
                }
                
                //Convertir cada diccionario al modelo Invite usando el método init?
                invitesArray.append(Invite(dictionary: inviteDic)!)
            }
            
            print(invitesArray)
            
            let newInvite = Invite(dictionary: data)
            
            invitesArray.forEach{ invite in
                
                if invite.username == newInvite?.username
                {
                    if invite.group == newInvite?.group
                    {
                        print("Usuario ya invitado al grupo")
                        onComplete(DataBaseServiceError.alreadyInvitedToGroup)
                        return
                    }
                }
                else
                {
                    onComplete(nil)
                }
            }
        }
    }
    
    func checkUserInGroup(username: String, group: String, onComplete: @escaping (Error?) -> Void)
    {
        //COMPROBAR QUE EL USUARIO NO ESTÁ YA EN EL GRUPO
        //1. Encontrarla llave del grupo a través del hijo "name"
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group)
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Obtener el nodo llave
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                //3. Leer valores del grupo seleccionado
                Database.database().reference(withPath: "groups/\(groupKey)/users")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //4. Los usuarios se almacenan como array, recogerlos para añadir el nuevo
                        var userArray = [String]()
                        if let users = snapshot.value as? [String]
                        {
                            userArray = users
                        }
                        
                        //5. Comprobar que el usuario no existe en el grupo
                        var userKey = ""
                        Database.database().reference().child("users")
                            .queryOrdered(byChild: "username")
                            .queryEqual(toValue: username)
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                if let dic = snapshot.value as? Dictionary<String, Any>
                                {
                                    userKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                                    
                                    if userArray.contains(userKey)
                                    {
                                        //Error personalizado
                                        print("Usuario ya en el grupo")
                                        onComplete(DataBaseServiceError.userAlreadyInGroup)
                                        return
                                    }
                                }
                                else
                                {
                                    print("No se ha obtenido el usuario")
                                }
                                onComplete(nil)
                        }
                }
        }
    }
    
    func inviteUser(username: String, group: String)
    {
        let data: Dictionary<String, Any> = ["username": username, "group": group, "timestamp" : NSDate().timeIntervalSince1970]
        
        //AÑADIR LA INVITACIÓN A LA BD
        //Crear nuevo nodo con los datos de la invitación
        let ref = Database.database().reference(withPath: "invites").childByAutoId()
        let inviteId = ref.key
        ref.setValue(data)
        
        //Añadir la invitación al usuario
        Database.database().reference().child("users")
            .queryOrdered(byChild: "username")
            .queryEqual(toValue: username)
            .observeSingleEvent(of: .value) { snapshot in
                
                let userKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                //Obtener todas las invitaciones del usuario
                Database.database().reference(withPath: "users/\(userKey)/invites")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //Recoger el array de invites del usuario
                        var userInvites = [String]()
                        if let invites = snapshot.value as? [String]
                        {
                            userInvites = invites
                        }
                        userInvites.append(inviteId!)
                        snapshot.ref.setValue(userInvites)
                }
        }
    }
    
    func retrieveInvites(for userId: String, onComplete: @escaping ([Invite]?) -> Void)
    {
        //1. Obtener las invites del usuario en forma de array
        Database.database().reference(withPath: "users/\(userId)/invites")
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Comprobar errores
                guard let userInvites = snapshot.value as? [String] else
                {
                    onComplete(nil)
                    return
                }
                
                //3. Con el array de grupos, sincronizar las peticiones de cada grupo para obtener la información
                let semaphore = DispatchGroup()
                var invites = [Invite]()
                
                userInvites.forEach { inviteId in
                    
                    //4. Entrar en el bloque
                    semaphore.enter()
                    
                    //5. Recibir datos
                    Database.database().reference(withPath: "invites/\(inviteId)")
                        .observeSingleEvent(of: .value) { snapshot in
                            
                            guard let dic = snapshot.value as? Dictionary<String, Any> else {
                                print("Dentro del guard")
                                semaphore.leave()
                                return
                            }
                            
                            //print(dic)
                            invites.append(Invite(dictionary: dic)!)
                            
                            //6. Salir del bloque
                            semaphore.leave()
                    }
                }
                
                //7. Con todas las respuestas obtenidas, notificar
                semaphore.notify(queue: .main) {
                    print("Finalizadas todas las peticiones")
                    
                    //8. Devolver datos con onComplete
                    onComplete(invites)
                }
        }
    }
    
    func joinGroupInvite(group: String, onComplete: @escaping (Error?) -> Void)
    {
        //PASO 1: Insertar el usuario en el grupo
        //1. Encontrarla llave del grupo a través del hijo "name"
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group)
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Obtener el nodo llave
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                //3. Leer valores del grupo seleccionado
                Database.database().reference(withPath: "groups/\(groupKey)/users")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //4. Los usuarios se almacenan como array, recogerlos para añadir el nuevo
                        var userArray = [String]()
                        if let users = snapshot.value as? [String]
                        {
                            userArray = users
                        }
                        
                        //5. Comprobar que el usuario no existe en el grupo
                        let userId = Auth.auth().currentUser!.uid
                        if userArray.contains(userId)
                        {
                            //Error personalizado
                            onComplete(DataBaseServiceError.userAlreadyInGroup)
                            return
                        }
                        
                        //6. Actualizar el nodo de grupos con el usuario nuevo
                        userArray.append(userId)
                        snapshot.ref.setValue(userArray)
                        
                        //PASO 2: Insertar el grupo en el nodo del usuario
                        //7. Recuperar el nodo del usuario
                        Database.database().reference(withPath: "users/\(userId)/groups")
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                //8. Recuperar grupos del usuario
                                var groupsArray = [String]()
                                if let groups = snapshot.value as? [String]
                                {
                                    groupsArray = groups
                                }
                                
                                //9. Añadir el grupo nuevo
                                groupsArray.append(groupKey)
                                snapshot.ref.setValue(groupsArray)
                                
                                //10. Finalizar
                                onComplete(nil)
                        }
                }
        }
    }
    
    func deleteInvite(invite: Invite, onComplete: @escaping (Error?) -> Void)
    {
        //Encontrar la invitación y borrarla del conjunto de invitaciones
        //1. Obtener las invites del usuario en forma de array
        let userId = Auth.auth().currentUser?.uid
        
        Database.database().reference(withPath: "users/\(userId!)/invites")
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Comprobar errores
                guard let userInvites = snapshot.value as? [String] else
                {
                    print("Error obteniendo invitación para borrar")
                    onComplete(DataBaseServiceError.gettingInvitesToDelete)
                    return
                }
                
                //3. Con el array de grupos, sincronizar las peticiones de cada grupo para obtener la información
                let semaphore = DispatchGroup()
                var invites = [String]()
                
                userInvites.forEach { inviteId in
                    
                    //4. Entrar en el bloque
                    semaphore.enter()
                    
                    //5. Recibir datos
                    Database.database().reference(withPath: "invites/\(inviteId)")
                        .observeSingleEvent(of: .value) { snapshot in
                            
                            guard let dic = snapshot.value as? Dictionary<String, Any> else {
                                print("Dentro del guard")
                                semaphore.leave()
                                return
                            }
                            
                            //print(dic)
                            let inviteRetrieved = Invite(dictionary: dic)!
                            if inviteRetrieved.group == invite.group
                            {
                                Database.database().reference(withPath: "invites/\(inviteId)").removeValue()
                            }
                            else
                            {
                                invites.append(inviteId)
                            }
                            
                            //6. Salir del bloque
                            semaphore.leave()
                    }
                }
                
                //7. Con todas las respuestas obtenidas, notificar
                semaphore.notify(queue: .main) {
                    print("Finalizadas todas las peticiones")
                    
                     Database.database().reference(withPath: "users/\(userId!)/invites").setValue(invites)
                    
                    onComplete(nil)
                }
        }
    }
    
    func leaveGroup(group: Group, onComplete: @escaping (Error?) -> Void)
    {
        //Encontrar la invitación y borrarla del conjunto de invitaciones
        //1. Obtener las invites del usuario en forma de array
        let userId = Auth.auth().currentUser?.uid
        
        Database.database().reference(withPath: "users/\(userId!)/groups")
            .observeSingleEvent(of: .value) { snapshot in
                
                //2. Comprobar errores
                guard let userGroups = snapshot.value as? [String] else
                {
                    print("Error obteniendo grupos para salirse")
                    onComplete(DataBaseServiceError.retreivingGroupsToLeave)
                    return
                }
                
                //3. Con el array de grupos, sincronizar las peticiones de cada grupo para obtener la información
                let semaphore = DispatchGroup()
                var groups = [String]()
                
                userGroups.forEach { groupId in
                    
                    //4. Entrar en el bloque
                    semaphore.enter()
                    
                    //5. Recibir datos
                    Database.database().reference(withPath: "groups/\(groupId)")
                        .observeSingleEvent(of: .value) { snapshot in
                            
                            guard let dic = snapshot.value as? Dictionary<String, Any> else {
                                print("Dentro del guard")
                                semaphore.leave()
                                return
                            }
                            
                            //print(dic)
                            let groupRetrieved = Group(dictionary: dic)!
                            if groupRetrieved.name == group.name
                            {
                                Database.database().reference(withPath: "groups/\(groupId)/users")
                                    .observeSingleEvent(of: .value) { snapshot in
                                        
                                        guard let groupUsers = snapshot.value as? [String] else
                                        {
                                            print("Error obteniendo usuarios para salirse")
                                            onComplete(DataBaseServiceError.retreivingGroupsToLeave)
                                            return
                                        }
                                        
                                        var users = [String]()
                                        groupUsers.forEach { userIden in
                                            
                                            if userIden != userId
                                            {
                                                users.append(userIden)
                                            }
                                        }
                                        
                                        Database.database().reference(withPath: "groups/\(groupId)/users").setValue(users)
                                }
                            }
                            else
                            {
                                groups.append(groupId)
                            }
                            
                            //6. Salir del bloque
                            semaphore.leave()
                    }
                }
                
                //7. Con todas las respuestas obtenidas, notificar
                semaphore.notify(queue: .main) {
                    print("Finalizadas todas las peticiones")
                    
                    Database.database().reference(withPath: "users/\(userId!)/groups").setValue(groups)
                    
                    onComplete(nil)
                }
        }
    }
    
    func downloadGroupImage(group: Group, onComplete: @escaping (UIImage?) -> Void)
    {
        let httpsReference = Storage.storage().reference(forURL: group.imageURL)
        
        httpsReference.getData(maxSize: 100 * 1024 * 1024) { data, error in
            
            if let error = error {
                
                onComplete(nil)
            } else {
                
                let image = UIImage(data: data!)
                onComplete(image)
            }
        }
    }
    
    func downloadPostImage(url: String, onComplete: @escaping (UIImage?) -> Void)
    {
        print(url)
        let httpsReference = Storage.storage().reference(forURL: url)
        
        httpsReference.getData(maxSize: 100 * 1024 * 1024) { data, error in
            
            if let error = error {
                
                onComplete(nil)
            } else {
                
                let image = UIImage(data: data!)
                print("La imagen descargada es: \(image)")
                onComplete(image)
            }
        }
    }
    
    func getAllGroupUsers(group: Group, onComplete: @escaping ([User]?) -> Void)
    {
        //1. Obtener los usuarios del grupo en forma de array
        Database.database().reference().child("groups")
            .queryOrdered(byChild: "name")
            .queryEqual(toValue: group.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                
                Database.database().reference(withPath: "groups/\(groupKey)/users")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        //2. Comprobar errores
                        guard let groupUsers = snapshot.value as? [String] else
                        {
                            onComplete(nil)
                            return
                        }
                        
                        //3. Con el array de grupos, sincronizar las peticiones de cada grupo para obtener la información
                        let semaphore = DispatchGroup()
                        var users = [User]()
                        
                        groupUsers.forEach { userId in
                            
                            //4. Entrar en el bloque
                            semaphore.enter()
                            
                            //5. Recibir datos
                            Database.database().reference(withPath: "users/\(userId)")
                                .queryOrdered(byChild: "name")
                                .observeSingleEvent(of: .value) { snapshot in
                                    
                                    guard let dic = snapshot.value as? Dictionary<String, Any> else {
                                        print("Dentro del guard")
                                        semaphore.leave()
                                        return
                                    }
                                    
                                    //print(dic)
                                    users.append(User(dictionary: dic)!)

                                    //6. Salir del bloque
                                    semaphore.leave()
                            }
                        }

                        //7. Con todas las respuestas obtenidas, notificar
                        semaphore.notify(queue: .main) {
                            print("Finalizadas todas las peticiones")
                            
                            //8. Devolver datos con onComplete
                            onComplete(users)
                        }
                }
        }
    }
    
    func updateGroupPic(group: Group, picture: Data)
    {
        let ref = Database.database().reference()
        
        //1. Subir la imagen storage
        let imagename = "\(group.name)-\(UUID().uuidString).png"
        
        //2. Crear metadata de la imagen
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        //3 Obtener acceso a storage con la url
        let refStorage = Storage.storage()
            .reference(forURL: "gs://focus-48642.appspot.com")
            .child("groupsImage/\(imagename)")
        
        //4. Subir datos de la imagen
        refStorage.putData(picture, metadata: metadata) { metadata, error in
            if let error = error
            {
                print("Error subiendo la foto: \(error)")
                //onComplete(error)
                return
            }
            
            //5. Si la imagen se sube, obtener url de descarga
            refStorage.downloadURL { url, error in
                
                if let error = error
                {
                    print("Error obteniendo url de descarga: \(error.localizedDescription)")
                    //onComplete(error)
                    return
                }
                
                Database.database().reference().child("groups")
                    .queryOrdered(byChild: "name")
                    .queryEqual(toValue: group.name)
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        let groupKey = (snapshot.children.allObjects.first as! DataSnapshot).key
                        
                        ref.child("groups/\(groupKey)/imageURL").setValue(url?.absoluteString)
                        print("Datos e imagen actualizados en la base de datos")
                }
            }
        }
    }
}

enum DataBaseServiceError: Error
{
    case userAlreadyInGroup, alreadyInvitedToGroup, gettingInvitesToDelete,
        retreivingGroupsToLeave
    
    static func checkErrorCode(_errorCode: Int) -> DataBaseServiceError
    {
        return .userAlreadyInGroup
    }
    
    static func checkErrorCode2(_errorCode: Int) -> DataBaseServiceError
    {
        return .alreadyInvitedToGroup
    }
    
    static func checkErrorCode3(_errorCode: Int) -> DataBaseServiceError
    {
        return .gettingInvitesToDelete
    }
    
    static func checkErrorCode4(_errorCode: Int) -> DataBaseServiceError
    {
        return .retreivingGroupsToLeave
    }
}

