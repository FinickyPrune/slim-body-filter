//
//  SBMainViewController.swift
//  SlimBody
//
//  Created by Anastasia Kravchenko on 22.09.2023.
//

import TinyConstraints

final class SBMainViewController: UIViewController {

    var viewModel: SBMainViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(galleryButton)
        view.addSubview(saveButton)
        view.addSubview(imageView)
        view.addSubview(filtersCollectionView)
        view.addSubview(filterIntensivityView)

        galleryButton.topToSuperview(offset: 10, usingSafeArea: true)
        galleryButton.leadingToSuperview(offset: 10)

        saveButton.topToSuperview(offset: 10, usingSafeArea: true)
        saveButton.trailingToSuperview(offset: 10)

        imageView.topToBottom(of: galleryButton, offset: 5)
        imageView.trailing(to: saveButton)
        imageView.leading(to: galleryButton)
        imageView.bottomToTop(of: filtersCollectionView, offset: -5)

        filtersCollectionView.trailingToSuperview()
        filtersCollectionView.leadingToSuperview()
        filtersCollectionView.bottomToSuperview(offset: -5, usingSafeArea: true)

        filterIntensivityView.edges(to: filtersCollectionView)

        filterIntensivityView.isHidden = true
        filtersCollectionView.isHidden = true
    }

    @objc private func tapHandler(_ sender: UIButton) {
        switch sender {
        case galleryButton:
            showImagePicker()
        case saveButton:
            viewModel?.didTapSave()
        case cancelIntensivityButton:
            viewModel?.didCancelValue()
            showIntensivityView(false)
            slimBodyView?.removeFromSuperview()
        case confirmIntensivityButton:
            viewModel?.didAcceptValue()
            showIntensivityView(false)
            slimBodyView?.removeFromSuperview()
        default: break
        }
    }

    private func showImagePicker() {
        DispatchQueue.main.async { [self] in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                present(self.imagePickerController, animated: true)
            }
        }
    }

    private lazy var galleryButton: UIButton = {
        let button: UIButton = UIButton()
        var configuration: UIButton.Configuration = UIButton.Configuration.filled()

        configuration.title = "MainViewController.galleryButtonTitle".localized
        configuration.image =  UIImage(systemName: "photo.on.rectangle.angled",
                                withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8.0
        configuration.baseBackgroundColor = .darkGray
        configuration.baseForegroundColor = .white

        button.configuration = configuration

        let height: CGFloat = 40
        button.height(height)

        button.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)

        return button
    }()

    private lazy var saveButton: UIButton = {
        let button: UIButton = UIButton()
        var configuration: UIButton.Configuration = UIButton.Configuration.filled()

        configuration.title = "MainViewController.saveButtonTitle".localized
        configuration.image =  UIImage(systemName: "square.and.arrow.down",
                                       withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8.0
        configuration.baseBackgroundColor = .darkGray
        configuration.baseForegroundColor = .white

        button.configuration = configuration

        let height: CGFloat = 40
        button.height(height)

        button.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)

        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePan))
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handlePinch))
        let rotationGesture = UIRotationGestureRecognizer(target: self,
                                                          action: #selector(handleRotation))
        imageView.addGestureRecognizer(panGesture)
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(rotationGesture)

        imageView.isUserInteractionEnabled = true

        return imageView
    }()

    private lazy var filtersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10

        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SBFilterCollectionViewCell.self, forCellWithReuseIdentifier: SBFilterCollectionViewCell.identifier)

        collectionView.showsHorizontalScrollIndicator = false

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let height: CGFloat = 80
        collectionView.height(height)

        return collectionView
    }()

    private lazy var filterIntensivityView: UIView = {
        let view: UIView = UIView()

        view.addSubview(intensivitySlider)
        view.addSubview(cancelIntensivityButton)
        view.addSubview(confirmIntensivityButton)

        intensivitySlider.trailingToSuperview(offset: 10)
        intensivitySlider.leadingToSuperview(offset: 10)
        intensivitySlider.topToSuperview()
        intensivitySlider.heightToSuperview(multiplier: 0.5)

        cancelIntensivityButton.topToBottom(of: intensivitySlider)
        cancelIntensivityButton.leading(to: intensivitySlider)
        cancelIntensivityButton.bottomToSuperview()

        confirmIntensivityButton.topToBottom(of: intensivitySlider)
        confirmIntensivityButton.trailing(to: intensivitySlider)
        confirmIntensivityButton.bottomToSuperview()

        return view
    }()

    private lazy var intensivitySlider: UISlider = {
        let slider: UISlider = UISlider()

        slider.addTarget(self, action: #selector(didChangeSliderValue), for: .valueChanged)

        return slider
    }()

    @objc private func didChangeSliderValue(_ sender: UISlider) {
        viewModel?.didChangeFilterValue(sender.value)
    }

    private lazy var confirmIntensivityButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(.checkmark, for: .normal)

        button.aspectRatio(1)

        button.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)

        return button
    }()

    private lazy var cancelIntensivityButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(.remove, for: .normal)

        button.aspectRatio(1)

        button.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)

        return button
    }()

    private lazy var imagePickerController: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self

        return picker
    }()

    private var slimBodyView: SlimBodyView?

    private func showIntensivityView(_ show: Bool) {
        UIView.animate(withDuration: 0.15) { [self] in
            filtersCollectionView.alpha = !show ? 1.0 : 0.0
            filtersCollectionView.isHidden = show
            filterIntensivityView.alpha = show ? 1.0 : 0.0
            filterIntensivityView.isHidden = !show
        }
        if show {
//             Cheking what filter is used to configure slider. Maybe it needs better solution in feature, when there will be more filters in app.
            guard let filter = viewModel?.selectedFilter?.filterName else { return }
            switch filter {
            case .none:
                break
            case .blur:
                intensivitySlider.minimumValue = 0.0
                intensivitySlider.maximumValue = 1.0
            case .slimBody:
                intensivitySlider.minimumValue = -1.0
                intensivitySlider.maximumValue = 1.0
            }
            intensivitySlider.value = viewModel?.selectedFilterValue ?? 0.0
        }
    }

    private func changeSliderToDefault() {
        intensivitySlider.value = 0.0
        viewModel?.didChangeFilterValue(intensivitySlider.value)
    }

}

extension SBMainViewController: SBMainViewModelDisplayDelegate {

    func viewModelDidRequestReloadingViews(_ viewModel: SBMainViewModel) {
        DispatchQueue.main.async { [self] in
            if let image = viewModel.currentImage {
                imageView.image = UIImage(ciImage: image)
                didChangePointToPixelScale()
            }
            filtersCollectionView.isHidden = false
        }
    }

    func viewModel(_ viewModel: SBMainViewModel, didChangeSlimBodyConfiguratorVisibility shouldShow: Bool) {
        slimBodyView?.removeFromSuperview()
        guard let image = imageView.image else { return }
        if shouldShow {
            // scale represents how many image pixels in one screen point.
            // WARNING: in PoC we now that image is Vertical and scaled to fit imageView. If image will have other orentation or scale mode formula maybe needs to be reimagined.
            let scale = image.size.width / view.frame.width
            let size = CGSize(width: SlimBodyView.initialWidth, height: SlimBodyView.initialHeight)
            // Initialize slimBodyView in center of IMAGE in imageView.
            slimBodyView = SlimBodyView(frame: CGRect(origin: CGPoint(x: -SlimBodyView.initialWidth/2,
                                                                      y: -SlimBodyView.initialHeight/2 + (view.frame.height - image.size.height/scale)/2), size: size)) // If image will have other orentation or scale mode formula maybe needs to be reimagined.
            slimBodyView?.isUserInteractionEnabled = false
            // Important for gesture recognizers.
            slimBodyView?.layer.anchorPoint = .zero

            didChangePointToPixelScale()
            view.addSubview(slimBodyView!)
            // Give slimBodyView proper translation.
            slimBodyView!.transform = slimBodyView!.transform.concatenating(CGAffineTransform(translationX: view.frame.width/2 - size.width/2,
                                                                                              y: view.frame.height/2 - size.height/2))
            slimBodyViewDidChangeTransform(transform: slimBodyView!.transform)
        } else {
            slimBodyView?.removeFromSuperview()
        }
    }

    func viewModel(_ viewModel: SBMainViewModel, didRequestShowingMessage message: String) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }

    func viewModel(_ viewModel: SBMainViewModel, didSelectImage image: CIImage) {
        imageView.image = UIImage(ciImage: image)
    }

}

extension SBMainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel?.didPick(image)
            picker.dismiss(animated: true)
        }
    }

}

extension SBMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.filtersCount ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SBFilterCollectionViewCell.identifier, for: indexPath) as? SBFilterCollectionViewCell {
            if let viewModel = viewModel {
                cell.update(with: viewModel.displayFilterNameFor(index: indexPath.row))
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectFilterWith(index: indexPath.row)
        showIntensivityView(true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let viewModel = viewModel else { return .zero }
        let width = (collectionView.frame.width - collectionView.contentInset.left * 2 - 10.0) / CGFloat(viewModel.filtersCount)
        return CGSize(width: width, height: collectionView.frame.height - 10)
    }

}

extension SBMainViewController {

    // Calculations provided to scale slimBodyView size in points to size in pixels for further applying on image

    func didChangePointToPixelScale() {
        guard let image = imageView.image else { return }
        let scale = image.size.width / view.frame.width // pixels in one point
        // WARNING: in PoC we now that image is Vertical and scaled to fit imageView. If image will have other orentation or scale mode formula maybe needs to be reimagined.
        viewModel?.didChangeSlimBody(scale)
    }

    func slimBodyViewDidChangeTransform(transform: CGAffineTransform) {
        viewModel?.didChangeSlimBody(transform)
    }

    //     All recognizers logic is based on transform matrix math.

    ///  Concatenate new transform matrix with translation with view's transform.
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let slimBodyView = slimBodyView, let superview = slimBodyView.superview else { return }
        changeSliderToDefault()
        let delta = sender.translation(in: superview)
        slimBodyView.transform = slimBodyView.transform.concatenating(CGAffineTransform(translationX: delta.x, y: delta.y))
        sender.setTranslation(CGPoint.zero, in: superview)
        slimBodyViewDidChangeTransform(transform: slimBodyView.transform)
    }

    ///  Define gesture direction. Concatenate new transform matrix with scale with view's transform.
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let slimBodyView = slimBodyView else { return }
        changeSliderToDefault()
        switch sender.state {
        case .began:

            let locationOne = sender.location(ofTouch: 0, in: slimBodyView)
            let locationTwo = sender.location(ofTouch: 1, in: slimBodyView)
            let diffX = locationOne.x - locationTwo.x
            let diffY = locationOne.y - locationTwo.y

            let bearingAngle = diffY == 0 ? CGFloat.pi / 2.0 : abs(atan(diffX/diffY))
            if bearingAngle < CGFloat.pi / 6.0 {
                slimBodyView.pinchDirection = .vertical
            } else if bearingAngle < CGFloat.pi / 3.0 {
                slimBodyView.pinchDirection = .mixed
            } else if bearingAngle <= CGFloat.pi / 2.0 {
                slimBodyView.pinchDirection = .horizontal
            }

        case .changed:
            var transform = slimBodyView.transform
            let center = sender.location(in: slimBodyView).applying(transform)

            transform = transform.concatenating(slimBodyView.transform.inverted())
            transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
            switch slimBodyView.pinchDirection {

            case .horizontal:
                transform = transform.concatenating(CGAffineTransform(scaleX: sender.scale, y: 1))
            case .vertical:
                transform = transform.concatenating(CGAffineTransform(scaleX: 1, y: sender.scale))
            case .mixed:
                transform = transform.concatenating(CGAffineTransform(scaleX: sender.scale, y: sender.scale))
            case .none:
                break
            }

            transform = transform.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
            transform = transform.concatenating(slimBodyView.transform)
            slimBodyView.transform = transform

            slimBodyViewDidChangeTransform(transform: slimBodyView.transform)
            slimBodyView.setNeedsDisplay()
            sender.scale = 1

        case .ended:
            slimBodyView.pinchDirection = .none
            slimBodyViewDidChangeTransform(transform: slimBodyView.transform)
        default:
            break
        }

    }

    /// Concatenate new transform matrix with rotation with view's transform.
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard let slimBodyView = slimBodyView else { return }
        changeSliderToDefault()
        var transform = slimBodyView.transform
        let center = sender.location(in: slimBodyView).applying(transform)
        transform = transform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: sender.rotation))
        transform = transform.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        slimBodyView.transform = transform
        slimBodyViewDidChangeTransform(transform: slimBodyView.transform)
        sender.rotation = 0
    }

}
