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
    @State private var lightAngle: Double = 0
    @State private var shadowOffset: CGSize = CGSize(width: 5, height: 5)

    // 3D Bear Colors
    private let bearMainColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    private let bearLightColor = Color(red: 0.8, green: 0.6, blue: 0.4)
    private let bearDarkColor = Color(red: 0.4, green: 0.25, blue: 0.1)
    private let bearBellyColor = Color(red: 0.9, green: 0.8, blue: 0.7)

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                // Bear Character with 3D effects
                ZStack {
                    // Drop shadow for 3D effect
                    bearShadow
                        .offset(shadowOffset)
                        .blur(radius: 8)
                        .opacity(0.3)

                    // Bear body
                    bearBody3D

                    // Bear head
                    bearHead3D
                        .offset(y: -80)
                }
                .scaleEffect(bearScale)
                .rotationEffect(.degrees(bearRotation))
                .rotation3DEffect(
                    .degrees(bearRotation * 0.3),
                    axis: (x: 0, y: 1, z: 0)
                )
                .offset(bearOffset)
                .onAppear {
                    startIdleAnimation()
                    startLightAnimation()
                }
                .onDisappear {
                    stopIdleAnimation()
                    stopLightAnimation()
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

    // MARK: - 3D Bear Components

    private var bearShadow: some View {
        ZStack {
            // Body shadow
            Ellipse()
                .fill(Color.black)
                .frame(width: 160, height: 200)

            // Head shadow
            Circle()
                .fill(Color.black)
                .frame(width: 120, height: 120)
                .offset(y: -80)
        }
    }

    private var bearBody3D: some View {
        ZStack {
            // Main body with 3D gradient
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            bearLightColor,
                            bearMainColor,
                            bearDarkColor
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.2),
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 160, height: 200)
                .overlay(
                    // Highlight for 3D effect
                    Ellipse()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    bearLightColor.opacity(0.8),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 100)
                        .offset(x: -20, y: -30)
                )

            // 3D Belly with realistic shading
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            bearBellyColor,
                            bearLightColor,
                            bearMainColor.opacity(0.8)
                        ]),
                        center: UnitPoint(x: 0.4, y: 0.3),
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 100, height: 140)
                .offset(y: 20)
                .overlay(
                    // Belly highlight
                    Ellipse()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 60)
                        .offset(x: -10, y: -10)
                )

            // 3D Arms
            bearArm3D
                .offset(x: -70, y: -20)
                .rotation3DEffect(.degrees(-15), axis: (x: 0, y: 1, z: 0))
            bearArm3D
                .offset(x: 70, y: -20)
                .rotation3DEffect(.degrees(15), axis: (x: 0, y: 1, z: 0))

            // 3D Legs
            bearLeg3D
                .offset(x: -40, y: 80)
                .rotation3DEffect(.degrees(-10), axis: (x: 0, y: 1, z: 0))
            bearLeg3D
                .offset(x: 40, y: 80)
                .rotation3DEffect(.degrees(10), axis: (x: 0, y: 1, z: 0))
        }
    }

    private var bearHead3D: some View {
        ZStack {
            // 3D Head with realistic shading
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            bearLightColor,
                            bearMainColor,
                            bearDarkColor
                        ]),
                        center: UnitPoint(x: 0.25, y: 0.25),
                        startRadius: 15,
                        endRadius: 80
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    // Head highlight for 3D effect
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.6),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .offset(x: -15, y: -15)
                )

            // 3D Ears
            bearEar3D
                .offset(x: -35, y: -35)
                .rotationEffect(.degrees(earWiggle))
                .rotation3DEffect(.degrees(-20), axis: (x: 1, y: 0, z: 0))
            bearEar3D
                .offset(x: 35, y: -35)
                .rotationEffect(.degrees(-earWiggle))
                .rotation3DEffect(.degrees(-20), axis: (x: 1, y: 0, z: 0))

            // 3D Eyes
            HStack(spacing: 25) {
                bearEye3D
                bearEye3D
            }
            .offset(y: -15)
            .scaleEffect(eyeScale)

            // 3D Snout
            bearSnout3D
                .offset(y: 10)

            // 3D Nose
            bearNose3D
                .offset(y: 5)

            // 3D Mouth
            bearMouth3D
                .scaleEffect(mouthScale)
                .offset(y: 25)
        }
    }

    // MARK: - 3D Bear Parts

    private var bearEar3D: some View {
        ZStack {
            // Ear base with 3D shading
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            bearLightColor,
                            bearMainColor,
                            bearDarkColor
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 5,
                        endRadius: 20
                    )
                )
                .frame(width: 30, height: 30)
                .overlay(
                    // Ear highlight
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 12, height: 12)
                        .offset(x: -3, y: -3)
                )

            // Inner ear with depth
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.pink.opacity(0.6),
                            bearDarkColor.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 15, height: 15)
        }
    }

    private var bearEye3D: some View {
        ZStack {
            // Eye socket shadow
            Circle()
                .fill(bearDarkColor.opacity(0.3))
                .frame(width: 22, height: 22)
                .offset(x: 1, y: 1)

            // Eye white with 3D effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.gray.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 12
                    )
                )
                .frame(width: 20, height: 20)

            // Pupil with depth
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black,
                            Color.gray.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 1,
                        endRadius: 8
                    )
                )
                .frame(width: 12, height: 12)
                .offset(y: isBeingTickled ? -2 : 0)

            // Eye shine/reflection
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
                .offset(x: 2, y: -2)

            // Additional small shine
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 2, height: 2)
                .offset(x: -1, y: 1)
        }
    }

    private var bearSnout3D: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        bearBellyColor,
                        bearLightColor,
                        bearMainColor
                    ]),
                    center: UnitPoint(x: 0.3, y: 0.2),
                    startRadius: 5,
                    endRadius: 25
                )
            )
            .frame(width: 40, height: 30)
            .overlay(
                // Snout highlight
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.5),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 20, height: 15)
                    .offset(x: -5, y: -3)
            )
    }

    private var bearNose3D: some View {
        ZStack {
            // Nose shadow
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 9, height: 9)
                .offset(x: 0.5, y: 0.5)

            // Main nose
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black,
                            Color.gray.opacity(0.8)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 1,
                        endRadius: 5
                    )
                )
                .frame(width: 8, height: 8)

            // Nose highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 2, height: 2)
                .offset(x: -1, y: -1)
        }
    }

    private var bearMouth3D: some View {
        Path { path in
            if isBeingTickled {
                // Happy giggling mouth with more curve
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 10, y: 10))
                // Add dimples
                path.move(to: CGPoint(x: -2, y: -2))
                path.addEllipse(in: CGRect(x: -2, y: -2, width: 3, height: 3))
                path.move(to: CGPoint(x: 19, y: -2))
                path.addEllipse(in: CGRect(x: 19, y: -2, width: 3, height: 3))
            } else {
                // Neutral mouth
                path.move(to: CGPoint(x: 5, y: 0))
                path.addLine(to: CGPoint(x: 15, y: 0))
            }
        }
        .stroke(Color.black, lineWidth: 2)
        .frame(width: 20, height: 10)
        .shadow(color: bearDarkColor.opacity(0.3), radius: 1, x: 0, y: 1)
    }

    private var bearArm3D: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        bearLightColor,
                        bearMainColor,
                        bearDarkColor
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 25, height: 60)
            .overlay(
                // Arm highlight
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12, height: 30)
                    .offset(x: -3, y: -5)
            )
            .rotationEffect(.degrees(isBeingTickled ? 15 : 0))
    }

    private var bearLeg3D: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        bearLightColor,
                        bearMainColor,
                        bearDarkColor
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 30, height: 50)
            .overlay(
                // Leg highlight
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 15, height: 25)
                    .offset(x: -3, y: -5)
            )
    }

    // MARK: - Animation Functions

    private func tickleBear() {
        guard !isBeingTickled else { return }

        isBeingTickled = true
        soundManager.playRandomGiggle()

        // Enhanced 3D tickle animations
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            bearRotation = [-5, 5, -3, 3, 0].randomElement() ?? 0
            bearScale = 1.15
            eyeScale = 1.3
            mouthScale = 1.4
            shadowOffset = CGSize(width: 8, height: 8)
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            bearOffset = CGSize(
                width: Double.random(in: -15...15),
                height: Double.random(in: -15...15)
            )
            lightAngle += 30
        }

        // Reset after tickle with 3D effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                bearScale = 1.0
                eyeScale = 1.0
                mouthScale = 1.0
                bearRotation = 0
                bearOffset = .zero
                shadowOffset = CGSize(width: 5, height: 5)
            }
        }
    }

    private func stopTickling() {
        isBeingTickled = false

        withAnimation(.easeOut(duration: 0.4)) {
            bearScale = 1.0
            eyeScale = 1.0
            mouthScale = 1.0
            bearRotation = 0
            bearOffset = .zero
            shadowOffset = CGSize(width: 5, height: 5)
        }
    }

    private func startIdleAnimation() {
        idleAnimationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            guard !isBeingTickled else { return }

            // Random idle movements with 3D effects
            let animations = [idleBounce, idleWiggle, idleBlink, idleEarWiggle, idleBreathing]
            animations.randomElement()?()
        }
    }

    private func stopIdleAnimation() {
        idleAnimationTimer?.invalidate()
        idleAnimationTimer = nil
    }

    private func startLightAnimation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            lightAngle = 360
        }
    }

    private func stopLightAnimation() {
        lightAngle = 0
    }

    private func idleBounce() {
        withAnimation(.easeInOut(duration: 0.6)) {
            bearScale = 1.08
            shadowOffset = CGSize(width: 7, height: 7)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.6)) {
                bearScale = 1.0
                shadowOffset = CGSize(width: 5, height: 5)
            }
        }
    }

    private func idleWiggle() {
        withAnimation(.easeInOut(duration: 0.4)) {
            bearRotation = 4
            shadowOffset = CGSize(width: 3, height: 6)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.4)) {
                bearRotation = -4
                shadowOffset = CGSize(width: 7, height: 6)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.4)) {
                bearRotation = 0
                shadowOffset = CGSize(width: 5, height: 5)
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
            earWiggle = 12
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                earWiggle = -12
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                earWiggle = 0
            }
        }
    }

    private func idleBreathing() {
        withAnimation(.easeInOut(duration: 1.5)) {
            bearScale = 1.03
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                bearScale = 1.0
            }
        }
    }
}
