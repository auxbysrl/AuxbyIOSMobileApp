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
    var layout = CarrousellLayout()
    
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
        carrusellCV.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        carrusellCV.collectionViewLayout = layout
        carrusellCV.contentInsetAdjustmentBehavior = .never
        carrusellCV.translatesAutoresizingMaskIntoConstraints = false
        carrusellCV.decelerationRate = .fast
        layout.scrollDirection = .horizontal
        layout.itemSize.width = carrusellCV.frame.width * 0.5
        layout.minimumLineSpacing = 30
    }
    
    func setTimer() {
        if offers.count > 0 {
            if layout.currentPage == offers.count - 1 {
                layout.currentPage = 0
            } else {
                layout.currentPage += 1
            }
            carrusellCV.scrollToItem(at: IndexPath(row: layout.currentPage, section: 0), at: .centeredHorizontally, animated: true)
            setBiggerCell()
        }
    }
    
    func setBiggerCell() {
        for otherCell in carrusellCV.visibleCells {
            if let indexPath = carrusellCV.indexPath(for: otherCell) {
                if indexPath.item != layout.currentPage {
                    UIView.animate(withDuration: 0.2) {
                        otherCell.transform = .identity
                    }
                }
            }
        }
        let indexPath = IndexPath(item: layout.currentPage, section: 0)
        if let cell = carrusellCV.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            setBiggerCell()
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
            if indexPath.item == layout.currentPage {
                cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                cell.transform = .identity
            }
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
        collectionView == categoriesCV ? CGSize(width: 174, height: 92) : CGSize(width: collectionView.frame.width * 0.5, height: collectionView.frame.height - 50)
    }
}
