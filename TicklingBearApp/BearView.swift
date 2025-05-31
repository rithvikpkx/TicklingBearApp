import SwiftUI

struct BearView: View {
    @StateObject private var soundManager = SoundManager()
    @State private var isBeingTickled = false
    @State private var bearOffset = CGSize.zero
    @State private var bearRotation: Double = 0
    @State private var eyeScale: CGFloat = 1.0
    @State private var mouthScale: CGFloat = 1.0
    @State private var idleAnimationTimer: Timer?
    @State private var bearScale: CGFloat = 1.0
    @State private var earWiggle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                // Bear Character
                ZStack {
                    // Bear body
                    bearBody

                    // Bear head
                    bearHead
                        .offset(y: -80)
                }
                .scaleEffect(bearScale)
                .rotationEffect(.degrees(bearRotation))
                .offset(bearOffset)
                .onAppear {
                    startIdleAnimation()
                }
                .onDisappear {
                    stopIdleAnimation()
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            tickleBear()
                        }
                        .onEnded { _ in
                            stopTickling()
                        }
                )

                Spacer()

                // Instructions
                Text("Tickle the bear! 🐻")
                    .font(.title2)
                    .foregroundColor(.brown)
                    .padding()
            }
        }
    }

    private var bearBody: some View {
        ZStack {
            // Main body
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.brown]),
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 160, height: 200)

            // Belly
            Ellipse()
                .fill(Color.brown.opacity(0.6))
                .frame(width: 100, height: 140)
                .offset(y: 20)

            // Arms
            bearArm
                .offset(x: -70, y: -20)
            bearArm
                .offset(x: 70, y: -20)

            // Legs
            bearLeg
                .offset(x: -40, y: 80)
            bearLeg
                .offset(x: 40, y: 80)
        }
    }

    private var bearHead: some View {
        ZStack {
            // Head
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.brown]),
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)

            // Ears
            bearEar
                .offset(x: -35, y: -35)
                .rotationEffect(.degrees(earWiggle))
            bearEar
                .offset(x: 35, y: -35)
                .rotationEffect(.degrees(-earWiggle))

            // Eyes
            HStack(spacing: 25) {
                bearEye
                bearEye
            }
            .offset(y: -15)
            .scaleEffect(eyeScale)

            // Snout
            Ellipse()
                .fill(Color.brown.opacity(0.7))
                .frame(width: 40, height: 30)
                .offset(y: 10)

            // Nose
            Circle()
                .fill(Color.black)
                .frame(width: 8, height: 8)
                .offset(y: 5)

            // Mouth
            bearMouth
                .scaleEffect(mouthScale)
                .offset(y: 25)
        }
    }

    private var bearEar: some View {
        Circle()
            .fill(Color.brown)
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .fill(Color.brown.opacity(0.6))
                    .frame(width: 15, height: 15)
            )
    }

    private var bearEye: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)

            Circle()
                .fill(Color.black)
                .frame(width: 12, height: 12)
                .offset(y: isBeingTickled ? -2 : 0)

            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
                .offset(x: 2, y: -2)
        }
    }

    private var bearMouth: some View {
        Path { path in
            if isBeingTickled {
                // Happy giggling mouth
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 10, y: 8))
            } else {
                // Neutral mouth
                path.move(to: CGPoint(x: 5, y: 0))
                path.addLine(to: CGPoint(x: 15, y: 0))
            }
        }
        .stroke(Color.black, lineWidth: 2)
        .frame(width: 20, height: 10)
    }

    private var bearArm: some View {
        Ellipse()
            .fill(Color.brown)
            .frame(width: 25, height: 60)
            .rotationEffect(.degrees(isBeingTickled ? 15 : 0))
    }

    private var bearLeg: some View {
        Ellipse()
            .fill(Color.brown)
            .frame(width: 30, height: 50)
    }

    // MARK: - Animation Functions

    private func tickleBear() {
        guard !isBeingTickled else { return }

        isBeingTickled = true
        soundManager.playRandomGiggle()

        // Tickle animations
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            bearRotation = [-5, 5, -3, 3, 0].randomElement() ?? 0
            bearScale = 1.1
            eyeScale = 1.2
            mouthScale = 1.3
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            bearOffset = CGSize(
                width: Double.random(in: -10...10),
                height: Double.random(in: -10...10)
            )
        }

        // Reset after tickle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                bearScale = 1.0
                eyeScale = 1.0
                mouthScale = 1.0
                bearRotation = 0
                bearOffset = .zero
            }
        }
    }

    private func stopTickling() {
        isBeingTickled = false

        withAnimation(.easeOut(duration: 0.3)) {
            bearScale = 1.0
            eyeScale = 1.0
            mouthScale = 1.0
            bearRotation = 0
            bearOffset = .zero
        }
    }

    private func startIdleAnimation() {
        idleAnimationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            guard !isBeingTickled else { return }

            // Random idle movements
            let animations = [idleBounce, idleWiggle, idleBlink, idleEarWiggle]
            animations.randomElement()?()
        }
    }

    private func stopIdleAnimation() {
        idleAnimationTimer?.invalidate()
        idleAnimationTimer = nil
    }

    private func idleBounce() {
        withAnimation(.easeInOut(duration: 0.6)) {
            bearScale = 1.05
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.6)) {
                bearScale = 1.0
            }
        }
    }

    private func idleWiggle() {
        withAnimation(.easeInOut(duration: 0.4)) {
            bearRotation = 3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.4)) {
                bearRotation = -3
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.4)) {
                bearRotation = 0
            }
        }
    }

    private func idleBlink() {
        withAnimation(.easeInOut(duration: 0.1)) {
            eyeScale = 0.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.1)) {
                eyeScale = 1.0
            }
        }
    }

    private func idleEarWiggle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            earWiggle = 10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                earWiggle = -10
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                earWiggle = 0
            }
        }
    }
}
