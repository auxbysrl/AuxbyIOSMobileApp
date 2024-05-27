//
//  ImagesSliderVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 08.05.2023.
//

import UIKit

class ImagesSliderVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageSlider: UICollectionView!
    @IBOutlet weak var imagesControl: UIPageControl!
    
    // MARK: - Public properties
    var vm: PreviewOrDetailsVM!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageSlider.layoutIfNeeded()
        if vm.currentImage > 0 {
            imageSlider.scrollToItem(at: IndexPath(row: self.vm.currentImage, section: 0), at: .centeredVertically, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func swipeImage(_ sender: UIPageControl) {
        imageSlider.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .top, animated: true)
        vm.currentImage = sender.currentPage
    }
   
}

private extension ImagesSliderVC {
    func setView() {
        if let offer = vm.offer {
            imagesControl.numberOfPages = offer.photos?.count ?? 1
        } else {
            imagesControl.numberOfPages = vm.photos.count
        }
        imagesControl.currentPage = vm.currentImage
        imagesControl.currentPageIndicatorTintColor = .secondary
        let color: UIColor = .secondary.withAlphaComponent(0.5)
        imagesControl.pageIndicatorTintColor = color
    }
}

extension ImagesSliderVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let offer = vm.offer {
            return offer.photos?.count ?? 0
        } else {
            return vm.photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCVCell.className, for: indexPath) as! ImageCVCell
        if let offer = vm.offer {
            cell.setCell(image: offer.photos![indexPath.row].url)
        } else {
            cell.setCell(newImage: vm.photos[indexPath.row])
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = imageSlider.contentOffset
        visibleRect.size = imageSlider.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = imageSlider.indexPathForItem(at: visiblePoint) else { return }
        imagesControl.currentPage = indexPath.row
        vm.currentImage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: imageSlider.frame.width, height: imageSlider.frame.height)
    }
}
