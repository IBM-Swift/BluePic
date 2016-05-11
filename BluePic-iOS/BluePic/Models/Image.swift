//
//  Image.swift
//  BluePic
//
//  Created by Alex Buck on 4/29/16.
//  Copyright © 2016 MIL. All rights reserved.
//

import UIKit

class Image: NSObject {

    
    var id : String?
    var caption : String?
    var fileName : String?
    var timeStamp : NSDate?
    var url : String?
    var usersName : String?
    var usersId : String?
    var width : CGFloat?
    var height : CGFloat?
    var image : UIImage?
    var latitude : String?
    var longitude : String?
    var city : String?
    var state : String?
    
    
    override init() {
        
    }
    
    init?(_ dict : [String : AnyObject]) {
        
        super.init()
  
            if let id = dict["_id"] as? String,
                let caption = dict["caption"] as? String,
                let fileName = dict["fileName"] as? String,
                let url = dict["url"] as? String,
                let timeStamp = dict["uploadedTs"] as? String,
                let user = dict["user"] as? [String : AnyObject],
                let usersName = user["name"] as? String,
                let usersId = user["_id"] as? String {
                
                self.id = id
                self.caption = caption
                self.fileName = fileName
                self.url = url
                self.usersName = usersName
                self.usersId = usersId
                
                if let width = dict["width"] as? CGFloat,
                    let height = dict["height"] as? CGFloat {
                        self.width = width
                        self.height = height
                }

                //set timeStamp
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                if let date = dateFormatter.dateFromString(timeStamp) {
                    
                    print("image date for \(caption) is \(date)")
                    self.timeStamp = date
                }
                

            }else{
                print("invalid image json")
                return nil
            }
        
    }

    
}
