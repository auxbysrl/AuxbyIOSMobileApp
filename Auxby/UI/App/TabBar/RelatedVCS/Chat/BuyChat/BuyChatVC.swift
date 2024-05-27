//
//  BuyChatVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 12.07.2023.
//

import UIKit

class BuyChatVC: UIViewController {
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
        vm.setButtons(isFirst: true)
    }
}

// MARK: - Private Methods
private extension BuyChatVC {
    func setView() {
        noOfferView.isHidden = !vm.buyChats.isEmpty
        cv.isHidden = vm.buyChats.isEmpty
        cv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
}

extension BuyChatVC:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.buyChats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCVCell.className, for: indexPath) as! ChatCVCell
        cell.setCell(chat: vm.buyChats[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversationVC = ConversationVC.asVC() as! ConversationVC
        conversationVC.vm = ConversationVM(chat: vm.buyChats[indexPath.row].chat)
        pushVC(conversationVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 60)
    }
}
