// MARK: custom text view
import Foundation
import SwiftUI
import UIKit

struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        context.coordinator.textView = textView
        textView.delegate = context.coordinator
        textView.layoutManager.delegate = context.coordinator
        textView.font = UIFont(name: "Heebo-Regular", size: 14)
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dynamicHeightTextView: self)
    }
}

class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
    var dynamicHeightTextView: CustomTextView
    weak var textView: UITextView?

    init(dynamicHeightTextView: CustomTextView) {
        self.dynamicHeightTextView = dynamicHeightTextView
    }

    func textViewDidChange(_ textView: UITextView) {
        self.dynamicHeightTextView.text = textView.text
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.textView else {
                return
            }
            let size = view.sizeThatFits(view.bounds.size)
            if self?.dynamicHeightTextView.height != size.height {
                self?.dynamicHeightTextView.height = size.height
            }
        }
    }
}
