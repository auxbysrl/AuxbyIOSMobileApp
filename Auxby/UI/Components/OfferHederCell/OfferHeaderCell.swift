//
//  OfferHeaderCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.11.2022.
//

import UIKit

class OfferHeaderCell: UICollectionReusableView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categoriesCV: UICollectionView!
    @IBOutlet weak var carrusellCV: UICollectionView!
    
    // MARK: - Private properties
    private var presentCategories: (() -> Void)?
    private var categories: [Category] = []
    private var offers: [Offer] = []
    
    // MARK: - Public properties
    var counter = 0
    var presentOneOffer:((Int) -> Void)?
    
    func setCell(categories: [Category], offers: [Offer], presentCategories: (() -> Void)?) {
        self.presentCategories = presentCategories
        categoriesCV.delegate = self
        categoriesCV.dataSource = self
        carrusellCV.delegate = self
        carrusellCV.dataSource = self
        let categoryCell = UINib(nibName: CategoriesCVCell.className, bundle: nil)
        categoriesCV.register(categoryCell, forCellWithReuseIdentifier: CategoriesCVCell.className)
        self.categories = categories
        categoriesCV.reloadData()
        categoriesCV.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.offers = offers
        carrusellCV.reloadData()
        carrusellCV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func setTimer() {
        if offers.count > 0 {
            carrusellCV.scrollToItem(at: IndexPath(row: counter, section: 0), at: .centeredHorizontally, animated: true)
            if counter == offers.count - 1 {
                counter = 0
            } else {
                counter += 1
            }
        }
    }
    
    @IBAction func goToCategories(_ sender: UIButton) {
        presentCategories?()
    }
}

extension OfferHeaderCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == categoriesCV ? categories.count : offers.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Perform your specific action when scrolling occurs
        guard let collectionView = scrollView as? UICollectionView else {
            return
        }
        if collectionView == carrusellCV {
            _ = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            
            guard let visibleIndexPath = collectionView.indexPathsForVisibleItems.first(where: { collectionView.bounds.contains(collectionView.layoutAttributesForItem(at: $0)?.frame ?? .zero) }) else {
                return
            }
            counter = visibleIndexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  CategoriesCVCell.className, for: indexPath) as! CategoriesCVCell
            cell.setCell(category: categories[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  CarrusellCell.className, for: indexPath) as! CarrusellCell
            cell.setCell(offer: offers[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCV {
            let currentCat = categories[indexPath.row]
            if currentCat.noOffers > 1 {
                let offersByCategory = OffersByCategoryVC.asVC() as! OffersByCategoryVC
                offersByCategory.vm = OffersByCategoryVM(selectedCategory: categories[indexPath.row])
                topVC().pushVC(offersByCategory)
            } else if currentCat.noOffers == 1 {
                if let offer = Offline.decode(key: .offers, type: [Offer].self)?.first(where: { $0.categoryId == currentCat.id }) {
                    let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
                    offerDetailsVC.vm = PreviewOrDetailsVM(offer: offer)
                    topVC().pushVC(offerDetailsVC)
                } else {
                    presentOneOffer?(currentCat.id)
                }
            }
        } else {
            let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            offerDetailsVC.vm = PreviewOrDetailsVM(offer: offers[indexPath.row])
            topVC().pushVC(offerDetailsVC)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView == categoriesCV ? CGSize(width: 174, height: 92) : CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
