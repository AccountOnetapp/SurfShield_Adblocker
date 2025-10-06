//
//  ScrollableScrollView.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import Foundation
import SwiftUI

struct InternalScrollViewHelper: UIViewRepresentable {
    @Binding var contentOffset: CGPoint
    @State private var scrollView: UIScrollView?

    func makeUIView(context: Context) -> some UIView {
        let view = ScrollViewIdentifier()
        view.scrollViewCompletion = { scrollView in
            self.scrollView = scrollView
        }
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        scrollView?.setContentOffset(contentOffset, animated: true)
    }
}

final class ScrollViewIdentifier: UIView {
    var scrollViewCompletion: ((UIScrollView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func didMoveToWindow() {
        guard let scrollView = superview?.superview?.superview as? UIScrollView else {
            return
        }
        self.scrollViewCompletion?(scrollView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

fileprivate struct ScrollContentOffsetModifier: ViewModifier {
    @Binding var contentOffset: CGPoint

    func body(content: Content) -> some View {
        content
            .background {
                InternalScrollViewHelper(contentOffset: $contentOffset)
            }
    }
}

extension View {
    func scrollToOffset(contentOffset: Binding<CGPoint>) -> some View {
        return modifier(ScrollContentOffsetModifier(contentOffset: contentOffset))
    }
}
