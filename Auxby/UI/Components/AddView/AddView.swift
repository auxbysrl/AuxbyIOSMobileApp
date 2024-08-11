//
//  AddView.swift
//  Auxby
//
//  Created by Eduard Hutu on 25.06.2024.
//

import UIKit

class AddView: UIView {
    // MARK: - IBOutlets
    @IBOutlet var defaultView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var goToAdd: (() -> Void)?
    var close: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
   
    func set(content: String, imageURL: String, showAdd: Bool) {
        text.text = content
        blur.isHidden = imageURL.isEmpty
        imageView.isHidden = imageURL.isEmpty
        imageView.setImage(from: imageURL)
        addButton.isHidden = !showAdd
    }
    
    @IBAction func goToAdd(_ sender: UIButton) {
        goToAdd?()
    }
    
    @IBAction func close(_ sender: UIButton) {
        close?()
    }
}

private extension AddView {
    func setView() {
        Bundle.main.loadNibNamed("AddView", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}
