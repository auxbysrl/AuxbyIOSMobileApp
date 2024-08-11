//
//  ListOfBiddersVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.08.2023.
//

import UIKit

class ListOfBiddersVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var cv: UICollectionView!
    
    // MARK: - Public properties
    var vm: ListOfBiddersVM!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - IBActions
    @IBAction func close(_ sender: UIButton) {
        dismissVC()
    }
}

// MARK: - Private Methods
private extension ListOfBiddersVC {
    func setView() {
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
}

extension ListOfBiddersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.bids.count > 10 ? 10 : vm.bids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BidCVCell.className, for: indexPath) as! BidCVCell
        cell.setCell(bid: vm.bids[indexPath.row], currencySymbol: vm.currencySymbol)
        return cell
}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 61)
    }
    
}
