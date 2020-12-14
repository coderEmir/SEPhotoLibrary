//
//  HXImageClipViewController.swift
//  HXImagePickerController
//
//  Created by HongXiangWen on 2019/3/15.
//  Copyright © 2019年 WHX. All rights reserved.
//

import UIKit

/// 底部安全高度
let SESafeBottomHeight: CGFloat = UIApplication.shared.statusBarFrame.height > 20 ? 34 : 0
/// 工具栏高度
let SEtoolBarHeight: CGFloat = 49.0

let toolBarHeight = SESafeBottomHeight + SEtoolBarHeight

class HXImageClipViewController: UIViewController {
    
    var imageModel: SEPhotoModel?
    
    var clipImageCallback: ((SEPhotoModel) -> ())?
    
    // MARK: -  懒加载
    
    /// 底部工具栏
    private lazy var imageToolView: SEImageToolView = {
        let imageToolView = SEImageToolView(viewType: SEImageToolViewTypeClip) { (type) in
            switch (type) {
                case SEImageToolViewCallbackTypeCancleEdit:
                    self.cancelBtnClicked()
                case SEImageToolViewCallbackTypeFinishEdit:
                    self.completeBtnClicked()
                case SEImageToolViewCallbackTypeReback:
                    self.restoreBtnClicked()
                case SEImageToolViewCallbackTypeRotate:
                    self.rotateBtnClicked()
                default:do {}
            }
            
        }
        imageToolView.backgroundColor = UIColor.black
        imageToolView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - toolBarHeight, width: UIScreen.main.bounds.width, height: toolBarHeight)
        return imageToolView
    }()
    
    private var clipScrollView: HXImageClipScrollView?
    
    private lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        return activityView
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var orientation : UIImage.Orientation = UIImage.Orientation.up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.backgroundColor = .black
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(activityView)
        view.addSubview(imageToolView)
        setupClipScrollView()
    }
    @objc func editImage(model: SEPhotoModel, clipImageCallback: @escaping ((SEPhotoModel) -> ())) {
        imageModel = model
        self.clipImageCallback = clipImageCallback
    }
    private func setupClipScrollView() {
        guard let imageModel = imageModel else { return }
        let contentInset = UIEdgeInsets(top: SESafeBottomHeight, left: 0, bottom: toolBarHeight, right: 0)
        if let editedImage = imageModel.editedImage as UIImage?{
            addClipScrollViewWithImage(editedImage, contentInset: contentInset)
        } else {
            activityView.startAnimating()
            SEPhotoManager.default().requestPreviewImage(imageModel.asset) { (image: UIImage) in
                self.activityView.stopAnimating()
                self.addClipScrollViewWithImage(image, contentInset: contentInset)
            }
        }
    }
    
    private func addClipScrollViewWithImage(_ image: UIImage, contentInset: UIEdgeInsets) {
        let clipScrollView = HXImageClipScrollView(frame: view.bounds, image: image, margin: 30, contentInset: contentInset)
        clipScrollView.canRecoveryClosure = { [weak self] (_, canRecovery) in
            guard let `self` = self else { return }
            self.imageToolView.rebackBtn.isEnabled = canRecovery
        }
        clipScrollView.prepareToScaleClosure = { [weak self] (_, prepareToScale) in
            guard let `self` = self else { return }
            self.imageToolView.cancelBtn.isEnabled = !prepareToScale
            self.imageToolView.confirmBtn.isEnabled = !prepareToScale
        }
        view.insertSubview(clipScrollView, at: 0)
        self.clipScrollView = clipScrollView
    }
    
    // MARK: - Actions
    
    @objc private func cancelBtnClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func restoreBtnClicked() {
        clipScrollView?.recovery()
    }
    
    @objc private func completeBtnClicked() {
        guard let clipScrollView = clipScrollView,
            let imageModel = imageModel else { return }
        activityView.startAnimating()
        clipScrollView.clipImage(isOriginImageSize: true) { [weak self] (image) in
            guard let `self` = self else { return }
            self.activityView.stopAnimating()
            imageModel.editedImage = image!
            self.clipImageCallback?(imageModel)
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func rotateBtnClicked() {
        switch orientation {
        case .up:
            orientation = .right
        case .right:
            orientation = .down
        case .down:
            orientation = .left
        case .left:
            orientation = .up
        
        default:
            orientation = .up
        }
        clipScrollView?.rotate(orientation: orientation)
    }
    
}
