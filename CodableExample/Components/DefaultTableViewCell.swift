//
//  DefaultTableViewCell.swift
//  CodableExample
//
//  Created by Alessandro Fiss Garcez on 14/03/24.
//

import UIKit

final class DefaultTableViewCell: UITableViewCell {

    static var identifier: String { "DefaultTableViewCell" }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(state: State) {
        textLabel?.text = state.text
    }
    
//    func set(imageData: ImageData) {
//        textLabel?.text = "is image"
//    }
//
//    func set(textData: TextData) {
//        textLabel?.text = "is text"
//    }
//
//    func set(embeddedData: Post) {
//        textLabel?.text = "is embedded"
//    }
    
    struct State {
        let text: String
    }
}
