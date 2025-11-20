import UIKit
final class SingleImageViewController: UIViewController {
   
    var photo: Photo!
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ShareButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        
        imageView.contentMode = .scaleAspectFit
        loadFullImage()
        
        scrollView.accessibilityIdentifier = "image_scroll_view"
        imageView.accessibilityIdentifier = "fullscreen_image"
        
    }
    
    private func loadFullImage() {
        guard let fullImageURL = URL(string: photo.largeImageURL) else { return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
        
        private func showError() {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Что-то пошло не так. Попробовать ещё раз?",
                preferredStyle: .alert
            )
            
            let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                self?.loadFullImage()
            }
            
            let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
            
            alert.addAction(retryAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }
    
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

