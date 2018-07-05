

import Foundation
import UIKit

final class DetailViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    var image: UIImage?
    var titleText: String?
    var dateText: Date?
    var descriptionText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        titleLabel.text = titleText
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = dateFormatter.string(from: dateText!)
        descriptionLabel.text = descriptionText
    }
}
