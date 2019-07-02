import UIKit

// MARK: - Extension NSAttributedString Image Protocol
extension NSMutableAttributedString {
    
    // https://www.hackingwithswift.com/example-code/system/how-to-insert-images-into-an-attributed-string-with-nstextattachment
    func appendImage(_ image: UIImage) {
        // MARK: Create our NSTextAttachment.
        let imageAttchment: NSTextAttachment = NSTextAttachment()
        imageAttchment.image = image

        // MARK: Wrap the attachment in its own attributed string so we can append it.
        let strImage: NSAttributedString = NSAttributedString(attachment: imageAttchment)
        self.append(strImage)
    }
}
