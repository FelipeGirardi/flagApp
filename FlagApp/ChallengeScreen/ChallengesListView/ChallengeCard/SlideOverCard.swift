import SwiftUI

struct SlideOverCard<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.getPosition(.bottom)()

    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return
            VStack(spacing: UIScreen.main.bounds.height / 50) {
                Handle()
                self.content()
                    .padding(.bottom, self.position == CardPosition.getPosition(.top)() ? UIScreen.main.bounds.height / 4.56 : 0)
            }
            .background(
                Image("Mountaineer")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .cornerRadius(30.0)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
            .offset(y: self.position + self.dragState.translation.height >= CardPosition.getPosition(.bottom)() ? CardPosition.getPosition(.bottom)() : (self.position + self.dragState.translation.height <= CardPosition.getPosition(.top)() ? CardPosition.getPosition(.top)() : self.position + self.dragState.translation.height))
            .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
            .gesture(drag)
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position + drag.translation.height
        let positionAbove: CardPosition = .top
        let positionBelow: CardPosition = .bottom
        let closestPosition: CardPosition

        if (cardTopEdgeLocation - CardPosition.getPosition(positionAbove)()) < (CardPosition.getPosition(positionBelow)() - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {
            self.position = CardPosition.getPosition(positionBelow)()
        } else if verticalDirection < 0 {
            self.position = CardPosition.getPosition(positionAbove)()
        } else {
            self.position = CardPosition.getPosition(closestPosition)()
        }
    }
}

enum CardPosition: CGFloat {
    case top
    case bottom

    func getPosition() -> CGFloat {
        switch self {
        case .top:
            return UIScreen.main.bounds.size.height * 0.1

        case .bottom:
            return UIScreen.main.bounds.size.height * 0.75
        }
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero

        case .dragging(let translation):
            return translation    // Drag para baixo: translation positivo; drag para cima: translation negativo
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false

        case .dragging:
            return true
        }
    }
}

struct Handle: View {
    private let handleThickness = CGFloat(4.0)
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 33, height: handleThickness)
            .foregroundColor(Color("Gray1"))
            .padding(.top)
    }
}
