import UIKit
import TinyConstraints

final class SBFilterCollectionViewCell: UICollectionViewCell {
    static let identifier = "SBFilterCollectionViewCell"

    override func layoutSubviews() {
        super.layoutSubviews()

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .darkGray
        layer.cornerRadius = 15.0

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
