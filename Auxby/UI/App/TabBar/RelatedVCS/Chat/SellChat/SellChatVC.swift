//
//  SellChatVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 12.07.2023.
//

import UIKit

class SellChatVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var noOfferView: UIView!

    // MARK: - Public properties
    var vm: ChatVM!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.setButtons(isFirst: false)
    }
}

private extension SellChatVC {
    func setView() {
        noOfferView.isHidden = !vm.sellChats.isEmpty
        cv.isHidden = vm.sellChats.isEmpty
        cv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
}

extension SellChatVC:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.sellChats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCVCell.className, for: indexPath) as! ChatCVCell
        cell.setCell(chat: vm.sellChats[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversationVC = ConversationVC.asVC() as! ConversationVC
        conversationVC.vm = ConversationVM(chat: vm.sellChats[indexPath.row].chat)
        pushVC(conversationVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 60)
    }
}
