//
//  Post.swift
//  CodableExample
//
//  Created by Alessandro Fiss Garcez on 22/02/24.
//

import Foundation

struct Post: Decodable {
    
    let author: Author
    let content: PostContent
    
    private enum `Type`: String, Decodable {
        case image
        case text
        case embedded
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.author = try container.decode(Author.self, forKey: .author)
        let type = try container.decodeIfPresent(`Type`.self, forKey: .type)
        
        switch type {
        case .image:
            guard let data = try container.decodeIfPresent(ImageData.self, forKey: .data) else {
                throw DecodingError.dataCorruptedError(forKey: .data,
                                                       in: container,
                                                       debugDescription: "No match image")
            }
            self.content = .image(data)
            return
        case .text:
            guard let data = try container.decodeIfPresent(TextData.self, forKey: .data) else {
                throw DecodingError.dataCorruptedError(forKey: .data,
                                                       in: container,
                                                       debugDescription: "No match text")
            }
            self.content = .text(data)
            return
        case .embedded:
            guard let data = try container.decodeIfPresent(Post.self, forKey: .data) else {
                throw DecodingError.dataCorruptedError(forKey: .data,
                                                       in: container,
                                                       debugDescription: "No match embedded")
            }
            self.content = .embedded(post: data)
            return
        default:
            throw DecodingError.dataCorruptedError(forKey: .type,
                                                   in: container,
                                                   debugDescription: "No match default")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case author
        case data
    }
}

struct Author: Codable {
    let name: String
    let profilePicture: String
}

struct ImageData: Codable {
    let imageUrl: String
    let text: String
}

struct TextData: Codable {
    let text: String
}

indirect enum PostContent: Decodable  {
    case image(ImageData)
    case text(TextData)
    case embedded(post: Post)
}
