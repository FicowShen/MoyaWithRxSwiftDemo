import Foundation

struct UserBasicInfo: Codable {
    let name: String
    let age: Int
}

struct UserHobbies: Codable {
    let hobbies: [String]
}

