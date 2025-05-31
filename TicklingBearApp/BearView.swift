import SwiftUI

// MARK: - Data Structures for Enhanced Features

struct TickleParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var life: Double
    var color: Color
    var size: CGFloat

    init(position: CGPoint) {
        self.position = position
        self.velocity = CGPoint(
            x: Double.random(in: -50...50),
            y: Double.random(in: -100...(-20))
        )
        self.life = 1.0
        self.color = [Color.yellow, Color.orange, Color.pink, Color.cyan].randomElement() ?? Color.yellow
        self.size = CGFloat.random(in: 4...12)
    }
}

enum FacialExpression {
    case neutral, happy, laughing, surprised, sleepy, excited
}

enum EnvironmentLighting {
    case daylight, sunset, night, party, cozy

    var backgroundColor: Color {
        switch self {
        case .daylight: return Color.white
        case .sunset: return Color.orange.opacity(0.1)
        case .night: return Color.blue.opacity(0.1)
        case .party: return Color.purple.opacity(0.1)
        case .cozy: return Color.yellow.opacity(0.05)
        }
    }

    var lightColor: Color {
        switch self {
        case .daylight: return Color.white
        case .sunset: return Color.orange
        case .night: return Color.blue
        case .party: return Color.purple
        case .cozy: return Color.yellow
        }
    }
}

struct BearView: View {
    @StateObject private var soundManager = SoundManager()
    @State private var isBeingTickled = false
    @State private var bearPosition = CGSize.zero  // Changed from bearOffset for dragging
    @State private var bearRotation: Double = 0
    @State private var eyeScale: CGFloat = 1.0
    @State private var mouthScale: CGFloat = 1.0
    @State private var idleAnimationTimer: Timer?
    @State private var bearScale: CGFloat = 1.0
    @State private var earWiggle: Double = 0
    @State private var lightAngle: Double = 0
    @State private var shadowOffset: CGSize = CGSize(width: 5, height: 5)

    // New enhanced features
    @State private var particles: [TickleParticle] = []
    @State private var facialExpression: FacialExpression = .neutral
    @State private var environmentLighting: EnvironmentLighting = .daylight
    @State private var soundReactiveScale: CGFloat = 1.0
    @State private var eyebrowAngle: Double = 0
    @State private var cheekPuff: CGFloat = 1.0
    @State private var isDragging = false
    @State private var dragOffset = CGSize.zero
    @State private var lastDragPosition = CGSize.zero

    // Environmental lighting timer
    @State private var environmentTimer: Timer?

    // 3D Bear Colors
    private let bearMainColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    private let bearLightColor = Color(red: 0.8, green: 0.6, blue: 0.4)
    private let bearDarkColor = Color(red: 0.4, green: 0.25, blue: 0.1)
    private let bearBellyColor = Color(red: 0.9, green: 0.8, blue: 0.7)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Environmental lighting background
                environmentLighting.backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 2.0), value: environmentLighting)

                VStack {
                    Spacer()

                    // Bear Character with all enhanced effects
                    ZStack {
                        // Particle effects layer
                        ForEach(particles) { particle in
                            Circle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .position(particle.position)
                                .opacity(particle.life)
                                .scaleEffect(particle.life)
                        }

                        // Drop shadow for 3D effect
                        bearShadow
                            .offset(shadowOffset)
                            .blur(radius: 8)
                            .opacity(0.3)

                        // Bear body with enhanced expressions
                        bearBody3D

                        // Bear head with complex facial expressions
                        bearHead3D
                            .offset(y: -80)
                    }
                    .scaleEffect(bearScale * soundReactiveScale)
                    .rotationEffect(.degrees(bearRotation))
                    .rotation3DEffect(
                        .degrees(bearRotation * 0.3),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .offset(x: bearPosition.width + dragOffset.width,
                           y: bearPosition.height + dragOffset.height)
                    .onAppear {
                        startIdleAnimation()
                        startLightAnimation()
                        startEnvironmentalLighting()
                        soundManager.onSoundPlayed = { [self] in
                            triggerSoundReactiveAnimation()
                        }
                    }
                    .onDisappear {
                        stopIdleAnimation()
                        stopLightAnimation()
                        stopEnvironmentalLighting()
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                    lastDragPosition = bearPosition
                                }
                                dragOffset = value.translation

                                // Check if this is a tickle (small movement) or drag (large movement)
                                let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                                if distance < 20 && !isBeingTickled {
                                    tickleBear(at: value.location)
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                bearPosition = CGSize(
                                    width: lastDragPosition.width + value.translation.width,
                                    height: lastDragPosition.height + value.translation.height
                                )
                                dragOffset = .zero
                                stopTickling()
                            }
                    )

                    Spacer()

                    // Enhanced instructions
                    VStack {
                        Text("Drag to move, tap to tickle! 🐻")
                            .font(.title2)
                            .foregroundColor(.brown)

                        Text("Environment: \(environmentLighting.description)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
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
            // 3D Head with realistic shading and environmental lighting
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            bearLightColor.blended(with: environmentLighting.lightColor, ratio: 0.2),
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
                    // Head highlight for 3D effect with environmental lighting
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    environmentLighting.lightColor.opacity(0.6),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .offset(x: -15, y: -15)
                )
                .scaleEffect(x: 1.0, y: cheekPuff) // Cheek puffing for expressions

            // Eyebrows for expressions
            bearEyebrows
                .offset(y: -35)

            // 3D Ears with expression-based movement
            bearEar3D
                .offset(x: -35, y: -35)
                .rotationEffect(.degrees(earWiggle + (facialExpression == .excited ? 15 : 0)))
                .rotation3DEffect(.degrees(-20), axis: (x: 1, y: 0, z: 0))
            bearEar3D
                .offset(x: 35, y: -35)
                .rotationEffect(.degrees(-earWiggle - (facialExpression == .excited ? 15 : 0)))
                .rotation3DEffect(.degrees(-20), axis: (x: 1, y: 0, z: 0))

            // 3D Eyes with complex expressions
            HStack(spacing: expressionBasedEyeSpacing) {
                bearEye3D
                bearEye3D
            }
            .offset(y: expressionBasedEyeOffset)
            .scaleEffect(eyeScale)

            // 3D Snout with expression-based scaling
            bearSnout3D
                .scaleEffect(facialExpression == .surprised ? 1.2 : 1.0)
                .offset(y: 10)

            // 3D Nose
            bearNose3D
                .offset(y: 5)

            // 3D Mouth with complex expressions
            bearMouth3D
                .scaleEffect(mouthScale)
                .offset(y: 25)

            // Cheek highlights for laughing
            if facialExpression == .laughing {
                cheekHighlights
            }
        }
    }

    // MARK: - Expression-based computed properties

    private var expressionBasedEyeSpacing: CGFloat {
        switch facialExpression {
        case .surprised: return 30
        case .laughing: return 20
        case .sleepy: return 22
        default: return 25
        }
    }

    private var expressionBasedEyeOffset: CGFloat {
        switch facialExpression {
        case .surprised: return -20
        case .sleepy: return -10
        default: return -15
        }
    }

    // MARK: - New Facial Expression Components

    private var bearEyebrows: some View {
        HStack(spacing: 25) {
            // Left eyebrow
            Path { path in
                path.move(to: CGPoint(x: 0, y: 5))
                path.addLine(to: CGPoint(x: 15, y: 0))
            }
            .stroke(bearDarkColor, lineWidth: 2)
            .rotationEffect(.degrees(eyebrowAngle))

            // Right eyebrow
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 15, y: 5))
            }
            .stroke(bearDarkColor, lineWidth: 2)
            .rotationEffect(.degrees(-eyebrowAngle))
        }
    }

    private var cheekHighlights: some View {
        HStack(spacing: 40) {
            Circle()
                .fill(Color.pink.opacity(0.6))
                .frame(width: 15, height: 15)
            Circle()
                .fill(Color.pink.opacity(0.6))
                .frame(width: 15, height: 15)
        }
        .offset(y: 5)
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
            switch facialExpression {
            case .neutral:
                path.move(to: CGPoint(x: 5, y: 0))
                path.addLine(to: CGPoint(x: 15, y: 0))

            case .happy, .laughing:
                // Happy/laughing mouth with big smile
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 10, y: facialExpression == .laughing ? 15 : 10))
                // Add dimples for laughing
                if facialExpression == .laughing {
                    path.move(to: CGPoint(x: -2, y: -2))
                    path.addEllipse(in: CGRect(x: -2, y: -2, width: 3, height: 3))
                    path.move(to: CGPoint(x: 19, y: -2))
                    path.addEllipse(in: CGRect(x: 19, y: -2, width: 3, height: 3))
                }

            case .surprised:
                // Open mouth for surprise
                path.addEllipse(in: CGRect(x: 8, y: -2, width: 4, height: 6))

            case .sleepy:
                // Small yawn
                path.move(to: CGPoint(x: 7, y: 0))
                path.addQuadCurve(to: CGPoint(x: 13, y: 0), control: CGPoint(x: 10, y: 3))

            case .excited:
                // Wide excited smile
                path.move(to: CGPoint(x: -2, y: 0))
                path.addQuadCurve(to: CGPoint(x: 22, y: 0), control: CGPoint(x: 10, y: 12))
            }
        }
        .stroke(Color.black, lineWidth: 2)
        .fill(facialExpression == .surprised ? Color.black.opacity(0.8) : Color.clear)
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

    private func tickleBear(at location: CGPoint = CGPoint.zero) {
        guard !isBeingTickled else { return }

        isBeingTickled = true
        soundManager.playRandomGiggle()

        // Create particle effects at tickle location
        createTickleParticles(at: location)

        // Set facial expression based on tickle intensity
        let expressions: [FacialExpression] = [.happy, .laughing, .excited]
        facialExpression = expressions.randomElement() ?? .happy

        // Enhanced 3D tickle animations with facial expressions
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            bearRotation = [-8, 8, -5, 5, 0].randomElement() ?? 0
            bearScale = 1.2
            eyeScale = facialExpression == .excited ? 1.5 : 1.3
            mouthScale = facialExpression == .laughing ? 1.6 : 1.4
            shadowOffset = CGSize(width: 10, height: 10)
            eyebrowAngle = 15
            cheekPuff = facialExpression == .laughing ? 1.1 : 1.0
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            lightAngle += 45
        }

        // Reset after tickle with enhanced effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                bearScale = 1.0
                eyeScale = 1.0
                mouthScale = 1.0
                bearRotation = 0
                shadowOffset = CGSize(width: 5, height: 5)
                eyebrowAngle = 0
                cheekPuff = 1.0
                facialExpression = .neutral
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

    // MARK: - New Enhanced Animation Functions

    private func createTickleParticles(at location: CGPoint) {
        let particleCount = Int.random(in: 8...15)
        for _ in 0..<particleCount {
            let particle = TickleParticle(position: location)
            particles.append(particle)
        }

        // Animate particles
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            for i in particles.indices.reversed() {
                particles[i].position.x += particles[i].velocity.x * 0.05
                particles[i].position.y += particles[i].velocity.y * 0.05
                particles[i].life -= 0.02
                particles[i].velocity.y += 2 // Gravity effect

                if particles[i].life <= 0 {
                    particles.remove(at: i)
                }
            }

            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }

    private func startEnvironmentalLighting() {
        environmentTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            let lightings: [EnvironmentLighting] = [.daylight, .sunset, .night, .party, .cozy]
            withAnimation(.easeInOut(duration: 2.0)) {
                environmentLighting = lightings.randomElement() ?? .daylight
            }
        }
    }

    private func stopEnvironmentalLighting() {
        environmentTimer?.invalidate()
        environmentTimer = nil
    }

    private func triggerSoundReactiveAnimation() {
        withAnimation(.easeInOut(duration: 0.2)) {
            soundReactiveScale = 1.1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                soundReactiveScale = 1.0
            }
        }

        // Random facial expression on sound
        let expressions: [FacialExpression] = [.happy, .excited, .surprised]
        withAnimation(.easeInOut(duration: 0.3)) {
            facialExpression = expressions.randomElement() ?? .happy
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                facialExpression = .neutral
            }
        }
    }

    private func idleBounce() {
        withAnimation(.easeInOut(duration: 0.6)) {
            bearScale = 1.08
            shadowOffset = CGSize(width: 7, height: 7)
            facialExpression = .happy
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.6)) {
                bearScale = 1.0
                shadowOffset = CGSize(width: 5, height: 5)
                facialExpression = .neutral
            }
        }
    }

    private func idleWiggle() {
        withAnimation(.easeInOut(duration: 0.4)) {
            bearRotation = 4
            shadowOffset = CGSize(width: 3, height: 6)
            facialExpression = .excited
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
                facialExpression = .neutral
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
            facialExpression = .surprised
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                earWiggle = -12
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                earWiggle = 0
                facialExpression = .neutral
            }
        }
    }

    private func idleBreathing() {
        withAnimation(.easeInOut(duration: 1.5)) {
            bearScale = 1.03
            facialExpression = .sleepy
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                bearScale = 1.0
                facialExpression = .neutral
            }
        }
    }
}

// MARK: - Extensions for Enhanced Features

extension Color {
    func blended(with color: Color, ratio: Double) -> Color {
        let ratio = max(0, min(1, ratio))
        // Simplified blending - in production you'd use proper color space conversion
        return Color(
            red: 0.8,
            green: 0.6,
            blue: 0.4
        ).opacity(1.0 - ratio).overlay(color.opacity(ratio))
    }
}

extension EnvironmentLighting {
    var description: String {
        switch self {
        case .daylight: return "Daylight ☀️"
        case .sunset: return "Sunset 🌅"
        case .night: return "Night 🌙"
        case .party: return "Party 🎉"
        case .cozy: return "Cozy 🕯️"
        }
    }
}
