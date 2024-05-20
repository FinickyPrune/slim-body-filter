import UIKit
import TinyConstraints

final class SBFilterCollectionViewCell: UICollectionViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .darkGray
        layer.cornerRadius = Const.cornerRadius

        addSubview(filterNameLabel)
        filterNameLabel.edgesToSuperview()
    }

    private lazy var filterNameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    func update(with name: String) {
        filterNameLabel.text = name
    }

}

private extension SBFilterCollectionViewCell {
    enum Const {
        static let cornerRadius: CGFloat = 15
    }
}
