//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by D on 06.08.2023.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingViewController()
        let secondPage = OnboardingViewController()
        
        firstPage.image = UIImage(named: "OnbBlue")
        secondPage.image = UIImage(named: "OnbRed")
        
        firstPage.infoText = "Отслеживайте только то, что хотите"
        secondPage.infoText = "Даже если это не литры воды и йога"
        
        return [firstPage, secondPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .ypGray
        pageControl.pageIndicatorTintColor = .ypBlack

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var leaveFromOnboardingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupView()
        activateConstraints()
        
    }
    
    @objc
    private func leaveButtonTapped() {
        
    }
    
    private func activateConstraints() {
        let buttonEdge: CGFloat = 20
        let buttonHeight: CGFloat = 60
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: leaveFromOnboardingButton.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            leaveFromOnboardingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            leaveFromOnboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonEdge),
            leaveFromOnboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonEdge),
            leaveFromOnboardingButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            leaveFromOnboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupView() {
        view.addSubViews(pageControl, leaveFromOnboardingButton)
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return nil
        }

        return pages[nextIndex]
    }

    
    
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
