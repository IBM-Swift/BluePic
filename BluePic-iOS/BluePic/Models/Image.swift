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
 **/

import UIKit


struct Tag {
    var label: String?
    var confidence: CGFloat?
}

struct Location {
    var name: String?
    var latitude : String?
    var longitude: String?
    var weather : Weather? // nil
    var city : String?
    var state : String?
}

struct Weather {
    var temperature: Int?
    var iconId: Int?
    var description: String?
}

class Image: NSObject {

    var id : String? // nil
    var caption : String?
    var fileName : String?
    var timeStamp : NSDate? // nil
    var url : String? // nil
    var width : CGFloat?
    var height : CGFloat?
    var image : UIImage?
    var location : Location?
    var tags : [Tag]? // nil
    var user : User?
    
    override init() {
        
    }
    
//    init(id: String) {
//        self.id = id
//    }
    
    init?(_ dict : [String : AnyObject]) {
        
//        super.init()
  
            if let id = dict["_id"] as? String,
                let caption = dict["caption"] as? String,
                let fileName = dict["fileName"] as? String,
                let url = dict["url"] as? String,
                let timeStamp = dict["uploadedTs"] as? String,
                let user = dict["user"] as? [String : AnyObject],
                usersName = user["name"] as? String,
                usersId = user["_id"] as? String{
            
                self.id = id
                self.caption = caption
                self.fileName = fileName
                self.url = url
                self.user = User(facebookID: usersId, name: usersName)

                
//                let userObject = User()
//                if let usersName = user["name"] as? String,
//                    let usersId = user["_id"] as? String{
//                    userObject.name = usersName
//                    userObject.facebookID = usersId
//                    
//                }

//                self.user = userObject
                
                //Parse widht and height data
                if let width = dict["width"] as? CGFloat,
                    let height = dict["height"] as? CGFloat {
                        self.width = width
                        self.height = height
                }
                
    
                //Parse location data
                if let location = dict["location"] as? [String : AnyObject]{
                    
                    var loc = Location()
                    
                    //Parse name
                    if let name = location["name"] as? String {
                        loc.name = name
                    }
                    
                    
                    //Parse Lat/Long
                    if let latitude = location["latitude"] as? CGFloat,
                    let longitude = location["longitude"] as? CGFloat {
                        loc.latitude = "\(latitude)"
                        loc.longitude = "\(longitude)"
                    }
                    
                    //Parse weather object
                    var weatherObject = Weather()
                    if let weather = location["weather"] as? [String : AnyObject] {
                        if let temperature = weather["temperature"] as? Int {
                            weatherObject.temperature = temperature
                        }
                        if let iconId = weather["iconId"] as? Int {
                            weatherObject.iconId = iconId
                        }
                        if let description = weather["description"] as? String {
                            weatherObject.description = description
                        }
                    }
                            
                    loc.weather = weatherObject
                        
                    self.location = loc
     
                }
                
                //Parse tags data
                var tagsArray = [Tag]()
                if let tags = dict["tags"] as? [[String: AnyObject]] {
                    for tag in tags {
                        if let label = tag["label"] as? String,
                            let confidence = tag["confidence"] as? CGFloat {
                        
                            var tag = Tag()
                            tag.label = label
                            tag.confidence = confidence
                            tagsArray.append(tag)
    
                        }
                    }
                }
                self.tags = tagsArray

                //set timeStamp
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                if let date = dateFormatter.dateFromString(timeStamp) {
            
                    self.timeStamp = date
                }
                

            }else{
                print("invalid image json")
                return nil
            }
        
    }

    
}
