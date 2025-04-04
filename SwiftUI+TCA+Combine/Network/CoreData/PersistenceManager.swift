//
//  PersistenceManager.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/5/24.
//

import CoreData

class PersistenceManager {
  static var shared = PersistenceManager()
  
  var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "GitHubFavorite")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  /// 저장된 데이터 조회
  func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
    do {
      let fetchResult = try context.fetch(request)
      return fetchResult
    } catch {
      print(error.localizedDescription)
      return []
    }
  }
  /// 즐겨찾기 저장
  func saveFavorite(favorite: Profile) {
    let entity = NSEntityDescription.entity(forEntityName: "MyFavorite", in: context)
    if let entity {
      let managedObject = NSManagedObject(entity: entity, insertInto: context)
      managedObject.setValue(favorite.initial, forKey: "initial")
      managedObject.setValue(favorite.userName, forKey: "userName")
      managedObject.setValue(favorite.profileURL, forKey: "profileURL")
      managedObject.setValue(favorite.isFavorite, forKey: "isFavorite")
      managedObject.setValue(favorite.repositoryURL, forKey: "repositoryURL")
      do {
        try context.save()
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  /// 즐겨찾기 삭제
  @discardableResult
  func deleteFavorite(object: NSManagedObject) -> Bool {
    context.delete(object)
    do {
      try context.save()
      return true
    } catch {
      return false
    }
  }
  /// 즐겨찾기 목록 수
  func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int? {
    do {
      let count = try context.count(for: request)
      return count
    } catch {
      return nil
    }
  }
  /// 즐겨찾기 전체 삭제
  @discardableResult
  func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> Bool {
    let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
    let delete = NSBatchDeleteRequest(fetchRequest: request)
    do {
      try context.execute(delete)
      return true
    } catch {
      print(error.localizedDescription)
      return false
    }
  }
}
