// Allows users to see full song titles without needing to make the window wider
// Measures text width vs. container width to determine if scrolling is needed
// Smoothly animates long titles from right to left in a continuous loop

import SwiftUI

struct ScrollingText: View {
	let text: String
	let font: Font
	let animation: Animation

	@State private var animate = false
	@State private var textWidth: CGFloat = 0
	@State private var containerWidth: CGFloat = 0

		// 10-second animation cycle
	init(text: String, font: Font = .title, animation: Animation = .linear(duration: 12).repeatForever(autoreverses: false)) {
		self.text = text
		self.font = font
		self.animation = animation
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
					// Hidden text to measure actual width
				Text(text)
					.font(font)
					.fixedSize()
					.background(
						GeometryReader { textGeometry in
							Color.clear.onAppear {
								textWidth = textGeometry.size.width
								containerWidth = geometry.size.width
							}
							.onChange(of: text) { _ in
								textWidth = textGeometry.size.width
								containerWidth = geometry.size.width
								animate = false
									// Restart animation after a brief delay
								DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
									animate = textWidth > containerWidth
								}
							}
						}
					)
					.opacity(0)

					// Visible scrolling text
				if textWidth > containerWidth {
					HStack(spacing: 50) {
						Text(text)
							.font(font)
							.fixedSize()
						Text(text)
							.font(font)
							.fixedSize()
					}
					.offset(x: animate ? -textWidth - 50 : 0)
					.animation(animate ? animation : nil, value: animate)
					.onAppear {
							// Start animation after a brief delay
						DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
							animate = true
						}
					}
				} else {
						// Short titles (if text fits) display normally without scrolling
					Text(text)
						.font(font)
						.frame(maxWidth: .infinity)
				}
			}
			.frame(width: geometry.size.width, alignment: .leading)
			.clipped()
		}
	}
}

#Preview {
	VStack {
		ScrollingText(text: "This is a very long song title that should scroll horizontally when it doesn't fit")
			.frame(width: 300, height: 40)

		ScrollingText(text: "Short Title")
			.frame(width: 300, height: 40)
	}
	.padding()
}
