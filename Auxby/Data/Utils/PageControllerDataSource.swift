//
//  PageControllerDataSource.swift
//  NDSports
//
//  Created by Senocico Stelian on 08.02.2022.
//

import UIKit

class PageControllerDataSource: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Public properties
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private(set) var pageControllers: [UIViewController]!
    private(set) var currentPageIndex = 0
    var selectAction: ((_ isFirst: Bool) -> Void)?
    // MARK: - Public methods
    func setPageController(vcs: [UIViewController], containerView: UIView, index: Int = 0, animated: Bool = true) {
        if vcs.isEmpty { return }
        pageControllers = vcs
        pageViewController.dataSource = self
        pageViewController.setViewControllers([pageControllers[index]], direction: .forward, animated: animated, completion: nil)
        pageViewController.view.frame = containerView.bounds
        addChildVC(pageViewController, toView: containerView)
    }
    
    /// Break the strong reference cycle for *pageControllers* array.
    /// You need manually to call this before the child view controller deinitialization
    func deInit() {
        pageControllers = nil
    }
    
    func goTo(index: Int, animated: Bool = true) {
        guard pageControllers?.indices.contains(index) == true else { return }
        let direction: UIPageViewController.NavigationDirection = index < currentPageIndex ? .reverse : .forward
        pageViewController.setViewControllers([pageControllers[index]], direction: direction, animated: animated, completion: nil)
        currentPageIndex = index
    }
    
    // MARK: - UIPageViewController data source implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pageControllers?.firstIndex(of: viewController) {
            return index > 0 ? pageControllers[index - 1] : nil
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pageControllers?.firstIndex(of: viewController) {
            return index < pageControllers.count - 1 ? pageControllers[index + 1] : nil
        }
        return nil
    }
}
