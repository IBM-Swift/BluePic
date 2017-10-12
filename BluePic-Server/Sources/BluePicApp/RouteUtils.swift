/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import CouchDB
import Kitura
import KituraNet
import LoggerAPI
import SwiftyJSON
import BluemixObjectStorage
import Dispatch

enum BluePicLocalizedError: LocalizedError {

    case getTagsFailed
    case noImagesByTag(String)
    case getAllImagesFailed
    case noImageId
    case noJsonData(String)
    case getUsersFailed
    case noUserId(String)
    case missingUserId
    case readDocumentFailed
    case addImageRecordFailed
    case getImagesFailed(String)
    case addUserRecordFailed(String)
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .getTagsFailed: return "Failed to obtain tags from database."
        case .noImagesByTag(let tag): return "Failed to find images with tag: \(tag)."
        case .getAllImagesFailed: return "Failed to retrieve all images."
        case .noImageId: return "Failed to obtain imageId."
        case .noJsonData(let imageId): return "Failed to obtain JSON data from database for imageId: \(imageId)."
        case .getUsersFailed: return "Failed to read users from database."
        case .noUserId(let userId): return "Failed to obtain userId: \(userId)."
        case .missingUserId: return "Failed to obtain userId."
        case .readDocumentFailed: return "Failed to read requested user document."
        case .addImageRecordFailed: return "Failed to create image record in Cloudant database."
        case .getImagesFailed(let userId): return "Failed to get images for \(userId)."
        case .addUserRecordFailed(let userId): return "Failed to add user: \(userId) to the system of records."
        case .requestFailed: return "Failed to process user request."
        }
    }
}

// Encapsulates helper functions that the endpoints use
extension ServerController {

  /**
   This method kicks off asynchronously an OpenWhisk sequence and returns immediately.
   This method should not wait for the outcome of the OpenWhisk sequence/actions.
   Once the OpenWhisk sequence completes execution, the sequence should invoke the
   '/push' endpoint to generate a push notification for the iOS client.

   - parameter imageId: The image ID of the JSON image document in Cloudant.

   */
  func processImage(withId imageId: String) {
    Log.verbose("imageId: \(imageId)")

    let headers = [
                    "Content-Type": "application/json",
                    "Authorization": "Basic \(openWhiskProps.authToken)"
                  ]

    let requestOptions: [ClientRequest.Options] = [
                                                    .method("POST"),
                                                    .schema("https://"),
                                                    .hostname(openWhiskProps.hostName),
                                                    .port(443),
                                                    .path(openWhiskProps.urlPath),
                                                    .headers(headers)
                                                   ]

    guard let requestBody = JSON(["imageId": imageId]).rawString() else {
      Log.error("Failed to create JSON string with imageId.")
      return
    }

    // Make REST call
    let req = HTTP.request(requestOptions) { resp in
      guard let resp = resp else {
        Log.error("Did not receive a response")
        return
      }

      guard resp.statusCode == HTTPStatusCode.OK || resp.statusCode == HTTPStatusCode.accepted else {
        Log.error("Status error code or nil reponse received from OpenWhisk.")
        Log.error("Status code: \(resp.statusCode)")
        var rawUserData = Data()
        do {
          _ = try resp.read(into: &rawUserData)
          let str = String(data: rawUserData, encoding: .utf8)
          print("Error response from OpenWhisk: \(String(describing: str))")
        } catch {
          Log.warning("Failed to read response data in processImage error state.")
        }
        return
      }

      do {
        var body = Data()
        try resp.readAllData(into: &body)
        let jsonResponse = JSON(data: body)
        print("OpenWhisk response: \(jsonResponse)")
      } catch {
        Log.error("Bad JSON document received from OpenWhisk.")
      }
    }

    // Kitura does not yet execute certain functionality asynchronously,
    // hence the need for this block.
    DispatchQueue.global().async {
        req.end(requestBody)
    }
  }

  /**
  * Gets a specific image document from the Cloudant database.
  *
  * - parameter database: Database instance
  * - parameter imageId:  String id of the image document to retrieve.
  * - parameter callback: Callback to use within async method.
  */
  func readImage(database: Database, imageId: String, callback: @escaping (Image?, Swift.Error?) -> Void) {
    let anyImageId = imageId as Database.KeyType
    let queryParams: [Database.QueryParameters] = [
                                                   .endKey([anyImageId, NSNumber(integerLiteral: 0)]),
                                                   .startKey([anyImageId, NSObject()])
                                                  ]
    readImagesByView("images_by_id", params: queryParams, database: database) { images, error in
      guard let images = images, let image = images.first, error == nil else {
        callback(nil, BluePicLocalizedError.getImagesFailed(imageId))
        return
      }
      callback(image, nil)
    }
  }

  func readImagesByView(_ view: String,
                        params: [Database.QueryParameters] = [],
                        database: Database,
                        callback: @escaping ([Image]?, Swift.Error?) -> Void) {

    var queryParams: [Database.QueryParameters] = [.descending(true), .includeDocs(true)]
    queryParams.append(contentsOf: params)

    database.queryByView(view, ofDesign: "main_design", usingParameters: queryParams) { document, error in
      do {
        guard error == nil, let document = document else {
          throw BluePicLocalizedError.getAllImagesFailed
        }

        let data: [Data] = try document.imagesToData()

        let images = try data.map { try self.decoder.decode(Image.self, from: $0) }

        callback(images, nil)

      } catch {
        Log.error("\(error)")
        callback(nil, error)
      }
    }
  }

  /**
   Method to parse a document to get image data out of it.

   - parameter document: json document with raw data

   - throws: processing error if can't parse document properly

   - returns: valid Json with just image data
   */
  func parseImages(document: JSON) throws -> JSON {
    guard let rows = document["rows"].array else {
      throw ProcessingError.image("Invalid images document returned from Cloudant!")
    }

    var images: [JSON] = []
    var index = 1
    while index <= (rows.count) {
      var imageRecord = rows[index]["doc"]
      imageRecord["user"] = rows[index-1]["doc"]
      massageImageRecord(containerName: imageRecord["user"]["_id"].stringValue, record: &imageRecord)
      images.append(imageRecord)
      index = index + 2
    }

    return constructDocument(records: images)
  }

  /**
   Method to parse a document to get image data for a specific user out of it.

   - parameter userId:   ID of user to get images for
   - parameter document: json document with raw data

   - throws: processing error if can't parse document properly

   - returns: valid Json with just image data
   */
  func parseImages(forUserId userId: String, usingDocument document: JSON) throws -> JSON {
    guard let rows = document["rows"].array else {
      throw ProcessingError.image("Invalid images document returned from Cloudant!")
    }

    let images: [JSON] = rows.map { row in
      var record = row["value"]
      massageImageRecord(containerName: userId, record: &record)
      return record
    }

    return constructDocument(records: images)
  }

  /**
   Converts a RouterRequest object to a more consumable JSON object.

   - parameter json: json object containing details about an image
   - parameter request: router request with all the data

   - throws: parsing error if request has invalid info

   - returns: valid Json with image data
   */
  func updateImageJSON(json: JSON, withRequest request: RouterRequest) throws -> JSON {
    var updatedJson = json

    guard let contentType = ContentType.sharedInstance.getContentType(forFileName: updatedJson["fileName"].stringValue) else {
      throw ProcessingError.image("Invalid image document!")
    }

    let userId = updatedJson["userId"].string ?? "anonymous"
    Log.verbose("Image will be uploaded under the following userId: '\(userId)'.")
    let uploadedTs = StringUtils.currentTimestamp()
    let imageURL = generateUrl(forContainer: userId, forImage: updatedJson["fileName"].stringValue)

    updatedJson["contentType"].stringValue = contentType
    updatedJson["url"].stringValue = imageURL
    updatedJson["userId"].stringValue = userId
    updatedJson["uploadedTs"].stringValue = uploadedTs
    updatedJson["type"].stringValue = "image"

    return updatedJson
  }

  /**
   Convenience method to create a URL for a container.

   - parameter containerName: name of the container
   - parameter imageName:     name of corresponding image

   - returns: URL as a String
   */
  func generateUrl(forContainer containerName: String, forImage imageName: String) -> String {
    //let url = "http://\(database.connProperties.host):\(database.connProperties.port)/\(database.name)/\(imageId)/\(attachmentName)"
    //let url = "\(config.appEnv.url)/images/\(imageId)/\(attachmentName)"
    let baseURL = "https://dal.objectstorage.open.softlayer.com/v1/AUTH_\(objStorageConnProps.projectID)"
    let url = "\(baseURL)/\(containerName)/\(imageName)"
    return url
  }

  /**
   Method that actually creates a container with the Object Storage service.

   - parameter name: name of the container to create
   - parameter completionHandler: callback to use on success or failure
   */
   func createContainer(withName name: String, completionHandler: @escaping (_ success: Bool) -> Void) {
     // Cofigure container for public access and web hosting
     let configureContainer = { (container: ObjectStorageContainer) -> Void in
       let metadata: Dictionary = [
                                  "X-Container-Meta-Web-Listings": "true",
                                  "X-Container-Read": ".r:*,.rlistings"
                                  ]
       container.updateMetadata(metadata: metadata) { error in
         if error != nil {
           Log.error("Could not configure container named '\(name)' for public access and web hosting.")
           completionHandler(false)
         } else {
           Log.verbose("Configured successfully container named '\(name)' for public access and web hosting.")
           completionHandler(true)
         }
       }
     }

     // Create container
     let createContainer = { (objStorage: ObjectStorage?) -> Void in
       if let objStorage = objStorage {
         objStorage.createContainer(name: name) { error, container in
           if let container = container, error == nil {
             configureContainer(container)
           } else {
             Log.error("Could not create container named '\(name)'.")
             completionHandler(false)
           }
         }
       } else {
         Log.verbose("Created successfully container named '\(name)'.")
         completionHandler(false)
       }
     }

     // Create, and configure container
     objectStorageConn.getObjectStorage(completionHandler: createContainer)
   }

  /**
   Method to store image binary in a container if it exsists.

   - parameter image:             image binary data
   - parameter name:              file name to store image as
   - parameter containerName:     name of container to use
   - parameter completionHandler: callback to use on success or failure
   */
   func store(image: Data,
              withName name: String,
              inContainer containerName: String,
              completionHandler: @escaping (_ success: Bool) -> Void) {
     // Store image in container
     let storeImage = { (container: ObjectStorageContainer) -> Void in
       container.storeObject(name: name, data: image) { error, _ in
         if let _ = error {
           Log.error("Could not save image named '\(name)' in container.")
           completionHandler(false)
         } else {
           Log.verbose("Stored successfully image '\(name)' in container.")
           completionHandler(true)
         }
       }
     }

     // Get reference to container
     let retrieveContainer = { (objStorage: ObjectStorage?) -> Void in
       if let objStorage = objStorage {
         objStorage.retrieveContainer(name: containerName) { error, container in
           if let container = container, error == nil {
             storeImage(container)
           } else {
             Log.error("Could not find container named '\(containerName)'.")
             completionHandler(false)
           }
         }
       } else {
         completionHandler(false)
       }
     }

     // Create, and configure container
     objectStorageConn.getObjectStorage(completionHandler: retrieveContainer)
   }

  /**
   Method to convert JSON data to a more usable format, adding and removing values as necessary.

   - parameter containerName: container to use
   - parameter record:        Json data to massage/modify
   */
  private func massageImageRecord(containerName: String, record: inout JSON) {
    //let id = record["_id"].stringValue
    //record["length"].int = record["_attachments"][fileName]["length"].int
    let fileName = record["fileName"].stringValue
    record["url"].stringValue = generateUrl(forContainer: containerName, forImage: fileName)
    _ = record.dictionaryObject?.removeValue(forKey: "userId")
    _ = record.dictionaryObject?.removeValue(forKey: "_attachments")
  }

  /**
   Method to simply get cleanly formatted values from a JSON document.

   - parameter document: JSON document with raw data

   - throws: parsing error if user JSON is invalid

   - returns: array of Json value objects
   */
  private func parseRecords(document: JSON) throws -> [JSON] {
    guard let rows = document["rows"].array else {
      throw ProcessingError.user("Invalid document returned from Cloudant!")
    }

    let records: [JSON] = rows.map({row in
      row["value"]
    })
    return records
  }

  /**
   Helper method to wrap parsed data up nicely in a JSON object.

   - parameter records: array of JSON data to wrap up

   - returns: JSON object containg data and number of items
   */
  private func constructDocument(records: [JSON]) -> JSON {
    var jsonDocument = JSON([:])
    jsonDocument["number_of_records"].int = records.count
    jsonDocument["records"] = JSON(records)
    return jsonDocument
  }
}
