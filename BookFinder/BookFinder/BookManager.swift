//
//  BookManager.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import Foundation
struct Book2 {
    var title: String
    var author: String
    var id: String
    init?(title: String, author: String, id: String){
        self.title = title
        self.author = author
        self.id = id
    }
}

struct BookDetails {
    var title: String?
    var author: String?
    var description: String?
    var publicationDate: Date?
    var ISBN: String?
}

enum JSONError: Error {
    case InvalidURL(String)
    case InvalidKey(String)
    case InvalidArray(String)
    case InvalidData
    case InvalidImage
    case indexOutOfRange
    
}

class BookManager {
    public static let sharedInstance = BookManager()
    
    private static let BOOKS_URL = "https://www.googleapis.com/books/v1/volumes"
    private static let BOOK_QUERY_TEMPLATE = [
        URLQueryItem(name: "maxResults", value: "10"),
        URLQueryItem(name: "fields", value: "items(id,volumeInfo(title,authors,publishedDate))")
    ]
    
    private static let BOOK_IMAGE_URL = "https://books.google.com/books/content"
    //?printsec=frontcover&img=1&source=gbs_api
    private static let BOOK_IMAGE_QUERY_TEMPLATE = [
        URLQueryItem(name: "printsec", value: "frontcover"),
        URLQueryItem(name: "img", value: "1"),
        URLQueryItem(name: "source", value: "gbs_api")
    ]
    
    var searchData: [Book2] = []
    var initialBooks:[Book] = [
    Book(title: "Harry Potter and the Sorcer's Stone", image: #imageLiteral(resourceName: "Harry"), auth: "J.K Rowling", desc: "Dope Book", wish: false)!,
    Book(title: "Cat In the Hat", image: #imageLiteral(resourceName: "cathat"), auth: "Dr.Seuss", desc: "Good Book")!,
    Book(title: "Hunger Game", image: #imageLiteral(resourceName: "hungerGames"), auth: "Collins", desc: "Drama", wish: false)!]
    
    public func getBook(atIndex index: Int) throws -> Book2 {
        print(searchData[index])
        return self.searchData[index]
    }
    
    public var count: Int {
        get {
            return searchData.count;
        }
    }
    
    public func search(withText text: String, _ completion: @escaping ()->()) throws {
        let session = URLSession.shared
        
        // Generate the query for this text
        var query = BookManager.BOOK_QUERY_TEMPLATE
        query.append(URLQueryItem(name: "q", value: text))
        
        guard let booksUrl = NSURLComponents(string: BookManager.BOOKS_URL) else {
            throw JSONError.InvalidURL(BookManager.BOOKS_URL)
        }
        
        booksUrl.queryItems = query
        
        // Generate the query url from the query items
        let url = booksUrl.url!
        
        session.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                guard let items = json["items"] as! [[String: Any]]? else {
                    throw JSONError.InvalidArray("items")
                }
                
                self.searchData = []
                
                for item in items {
                    guard let id = item["id"] as! String? else {
                        throw JSONError.InvalidKey("id")
                    }
                    
                    guard let volumeInfo = item["volumeInfo"] as! [String: AnyObject]? else {
                        throw JSONError.InvalidKey("volumeInfo")
                    }
                    
                    let title = volumeInfo["title"] as? String ?? "Title not available"
                    
                    var authors = "No author information"
                
                    if let authorsArray = volumeInfo["authors"] as! [String]? {
                        authors = authorsArray.joined(separator: ", ")
                    }
                    
                    let book = Book2(title: title, author: authors, id: id)
                    self.searchData.append(book!)
                    
                }
                
                
            } catch  {
                print("Error thrown: \(error)")
            }
            completion()
        }).resume()
    }
    
    public func getDetails(withID id: String, _ completion: @escaping (BookDetails)->()) throws {
        let session = URLSession.shared
        
        guard let bookUrl = NSURLComponents(string: BookManager.BOOKS_URL + "/" + id) else {
            throw JSONError.InvalidURL(BookManager.BOOKS_URL)
        }
        
        print(bookUrl)
        
        session.dataTask(with: bookUrl.url!, completionHandler: {(data, response, error) -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                guard let info = json["volumeInfo"] as! [String: Any]? else {
                    throw JSONError.InvalidArray("volumeInfo")
                }
                
                let title = info["title"] as? String ?? "Title not available"
                
                var authors: String? = nil
                
                if let authorsArray = info["authors"] as! [String]? {
                    authors = authorsArray.joined(separator: ", ")
                }
                
                let description = info["description"] as? String ?? "Description not available"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                
                var pubDate: Date? = nil
                if let dateString = info["publishedDate"] as! String? {
                    print(dateString)
                    pubDate = dateFormatter.date(from: dateString)
                }
                
                var isbn: String? = nil
                if let isbns = info["industryIdentifiers"] as! [[String: Any]]? {
                    for isbnObject in isbns {
                        if let isbnType = isbnObject["type"] as! String? {
                            if isbnType == "ISBN_10" {
                                isbn = isbnObject["identifier"] as? String ?? "N/A"
                                break
                            }
                        }
                    }
                }
                
                completion(BookDetails(title: title, author: authors, description: description, publicationDate: pubDate, ISBN: isbn))
            } catch {
                print("Error thrown: \(error)")
            }
        }).resume()
    }
    
    public func getImage(withID id: String, _ completion: @escaping (Data)->()) throws {
        guard let bookUrl = NSURLComponents(string: BookManager.BOOK_IMAGE_URL) else {
            throw JSONError.InvalidURL(BookManager.BOOK_IMAGE_URL)
        }
        
        var query = BookManager.BOOK_IMAGE_QUERY_TEMPLATE
        query.append(URLQueryItem(name: "id", value: id))
        
        bookUrl.queryItems = query
        
        DispatchQueue.global(qos: .background).async {
            let data = try? Data(contentsOf: bookUrl.url!)
            completion(data!)
        }
    }
    /*
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
     let requestCourse = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
     
     var courses2:[Course] = [
         Course(name: "IT 191-Introduction to Professional Practice", description: "Researching available positions, interpreting job descriptions, interview skills, preparing a resume, benefits of a Professional Practice experience.", views: 0, fav: false)!,
         Course(name: "IT 354-Advanced Web Development", description: "Theory and practice of state-of-the-art technologies for application development for the Web including service-oriented and mobile systems.", views: 0, fav: false)!].sorted(by: {$0.name < $1.name})
     var copy = [Course]()
     var top3 = [Course]()
     var coursesCoreData:[Course] = []
     
     let requestSettings = NSFetchRequest<NSFetchRequestResult>(entityName: "SettingsClass")
     var color: Bool = false
     var pushNotify: Bool = false
     
     func savePush(newPush: Bool){
         pushNotify = newPush
         setSettings()
     }
     func saveColor(colorSwap: Bool){
         color = colorSwap
         setSettings()
     }
     func setSettings(){
         let settingEntity = NSEntityDescription.entity(forEntityName: "SettingsClass", in: context.viewContext)
         let updatedSettings = NSManagedObject(entity: settingEntity!, insertInto: context.viewContext)
         updatedSettings.setValue(color, forKey: "color")
         updatedSettings.setValue(pushNotify, forKey: "pushNotify")
         do{
             try context.viewContext.save()
             print("Settings have been updated")
         } catch{
             print("Failed to update Settings")
         }
         
     }
     
     func addCourse(course: Course){
         coursesCoreData.append(course)
         coursesCoreData = coursesCoreData.sorted(by: {$0.name < $1.name})
         saveCourses()
     }
     func favList() -> [Course]{
         copy = coursesCoreData.filter {$0.fav == true}
         return copy
     }
     func favSet(course: Course){
         if let index = self.coursesCoreData.firstIndex(where: {$0.name == course.name}) {
                coursesCoreData[index] = course
         }
         saveCourses()
     }
     func saveFav() {
         saveCourses()
     }
     func count() -> Int{
         return coursesCoreData.count
     }
     func noFavs(){
         coursesCoreData = coursesCoreData.map{course in
             var tempCourse:Course = course
             tempCourse.setFav(false)
             return tempCourse
         }
         saveCourses()
     }
     func initialSave(){
         let entity = NSEntityDescription.entity(forEntityName: "Course", in: context.viewContext)
         
         for course in CourseHandler.sharedInstance.courses2{
             let newEntity = NSManagedObject(entity: entity!, insertInto: context.viewContext)
             newEntity.setValue(course.getCourseName(), forKey: "name")
             newEntity.setValue(course.getCourseDescription(), forKey: "courseDescription")
             newEntity.setValue(course.getView(), forKey: "visit")
             newEntity.setValue(course.getFav(), forKey: "fav")
         }
         do{
             try context.viewContext.save()
             print("Initial data has been saved")
         }catch{
             print("Initial save failed")
         }
     }
     
     func saveCourses(){
         deleteAll()
         let entity = NSEntityDescription.entity(forEntityName: "Course", in: context.viewContext)
         for course in CourseHandler.sharedInstance.coursesCoreData{
             let newEntity = NSManagedObject(entity: entity!, insertInto: context.viewContext)
             newEntity.setValue(course.getCourseName(), forKey: "name")
             newEntity.setValue(course.getCourseDescription(), forKey: "courseDescription")
             newEntity.setValue(course.visit, forKey: "visit")
             newEntity.setValue(course.getFav(), forKey: "fav")
         }
         do{
             try context.viewContext.save()
             print("New data has been saved")
         }catch{
             print("Failed to save data")
         }
     }
     func deleteAll() {
         let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: requestCourse)
         do {
             try context.viewContext.execute(batchDeleteRequest)
         } catch {
             print("All is deleted")
         }
     }
     func getCourses(){
         requestCourse.returnsObjectsAsFaults = false
         
         do{
             let result = try self.context.viewContext.fetch(requestCourse)
             for data in result as! [NSManagedObject]{
                 coursesCoreData.append(Course(name: data.value(forKey: "name") as! String, description: data.value(forKey: "courseDescription") as! String, views: data.value(forKey: "visit") as! Int, fav: data.value(forKey: "fav") as! Bool)!)
             }
             coursesCoreData = coursesCoreData.sorted(by: {$0.name < $1.name})
         } catch{
             
         }
     }
     */
}
