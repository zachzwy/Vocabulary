//
//  yandexTranslate.swift
//  Vocabulary
//
//  Created by zach on 1/7/19.
//  Copyright © 2019 wenyu. All rights reserved.
//

import Foundation

public struct yandexTranslateParams {
    
    public init() {
    }
    
    public init(source:String, target:String, text:String) {
        self.source = source
        self.target = target
        self.text = text
    }
    
    public var source = "en"
    public var target = "zh"
    public var text = "hello world"
}

open class yandexTranslate {
    public var apiKey = ""
    public init() {
    }
    
    open func translate(params:yandexTranslateParams, callback:@escaping (_ translatedText:String) -> ()) {
        
        guard apiKey != "" else {
            print("Warning: You should set the api key before calling the translate method.")
            return
        }
        
        if let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            
            if let url = URL(string: "https://translate.yandex.net/api/v1.5/tr.json/translate?key=\(self.apiKey)&text=\(urlEncodedText)&lang=\(params.source)-\(params.target)&[format=\("plain")]&[callback=\(callback)]") {
                
                let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        print("Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        guard httpResponse.statusCode == 200 else {
                            if let data = data {
                                print("Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            return
                        }
                        
                        do {
                            if let data = data {
                                if let json = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                    if let jsonData = json["text"] as? [String] {
                                        callback(jsonData[0])
                                    }
                                }
                            }
                        } catch {
                            print("Serialization failed: \(error.localizedDescription)")
                        }
                    }
                })
                httprequest.resume()
            }
        }
    }
}

