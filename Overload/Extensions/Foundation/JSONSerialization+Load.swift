//
//  JSONSerialization+Load.swift
//  Overload
//
//  Created by Eric Schulte on 12/3/20.
//

import Foundation

extension JSONSerialization {
    static func load<T: Decodable>(fileName: String) -> T? {
       let decoder = JSONDecoder()
       guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let exercises = try? decoder.decode(T.self, from: data)
       else {
            return nil
       }

       return exercises
    }
}
