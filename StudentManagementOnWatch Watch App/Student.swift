//
//  Student.swift
//  StudentManagementOnWatch Watch App
//
//  Created by Hydan on 22/9/24.
//

import Foundation

struct Student: Identifiable, Codable {
    var id: Int
    var name: String
    var age: Int
    var gender: String
}
