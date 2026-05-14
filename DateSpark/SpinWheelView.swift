import SwiftUI

@MainActor
struct SpinWheelView: View {
    let onSelect: @MainActor (QuestionCategory) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var rotation:         Double            = 0
    @State private var isSpinning:       Bool              = false
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var showResult:       Bool              = false

    private let categories = QuestionCategory.allCases.filter { $0 != .custom }
    
    private var wheelSize: CGFloat {
        horizontalSizeClass == .regular ? 400 : 270
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CATEGORY WHEEL")
                        .font(.dsLabel(9))
                        .tracking(4)
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                    Text("Spin for a theme")
                        .font(.dsDisplay(22, weight: .light))
                        .foregroundColor(Color.dsPrimary)
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .padding(.bottom, 22)

            HairlineDivider()

            // Wheel + glow
            ZStack {
                // Atmospheric glow behind wheel
                if let cat = selectedCategory {
                    GlowOrb(color: cat.accentColor.opacity(0.2), size: wheelSize + 10, blur: 60)
                        .animation(.easeInOut(duration: 0.6), value: cat.rawValue)
                }

                WheelGraphic(categories: categories, rotation: rotation)
                    .frame(width: wheelSize, height: wheelSize)

                // Pointer — gold triangle
                VStack {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: horizontalSizeClass == .regular ? 18 : 14))
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                        .shadow(color: Color.dsGold.opacity(0.6), radius: 6)
                        .offset(y: 2)
                    Spacer()
                }
                .frame(height: wheelSize + 18)

                // Center cap
                ZStack {
                    let capSize: CGFloat = horizontalSizeClass == .regular ? 80 : 58
                    Circle()
                        .fill(Color.dsBackground)
                        .frame(width: capSize, height: capSize)
                        .overlay(
                            Circle()
                                .stroke(LinearGradient.dsGoldGradient, lineWidth: 0.8)
                        )
                        .shadow(color: Color.black.opacity(0.5), radius: 8)
                    Image("spark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: horizontalSizeClass == .regular ? 44 : 32)
                            .tracking(3)

                }
            }
            .padding(.vertical, 28)

            HairlineDivider()

            // Result / Action area
            Group {
                if showResult, let cat = selectedCategory {
                    HStack(alignment: .center, spacing: 16) {
                        // Colour swatch
                        RoundedRectangle(cornerRadius: 3)
                            .fill(cat.accentColor)
                            .frame(width: 4, height: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(cat.localizedName)
                                .font(.dsLabel(9))
                                .tracking(3)
                                .textCase(.uppercase)
                                .foregroundColor(cat.accentColor)
                            Text(cat.localizedDescription)
                                .font(.dsLabel(13, weight: .regular))
                                .foregroundColor(Color.dsSecondary)
                        }

                        Spacer()

                        Button { 
                            HapticManager.shared.buttonTap()
                            onSelect(cat) 
                        } label: {
                            HStack(spacing: 8) {
                                Text("Begin")
                                    .font(.dsDisplay(15, weight: .regular))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .light))
                            }
                            .foregroundColor(Color.dsBackground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 13)
                            .background(
                                ZStack {
                                    LinearGradient.dsGoldGradient
                                    LinearGradient(colors: [Color.white.opacity(0.1), Color.clear], startPoint: .top, endPoint: .bottom)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .shadow(color: Color.dsGold.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Button { 
                        HapticManager.shared.buttonTap()
                        Task { await spin() } 
                    } label: {
                        HStack(spacing: 12) {
                            if isSpinning {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(Color.dsBackground)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 13, weight: .regular))
                            }
                            Text(isSpinning ? "Spinning…" : "Spin the Wheel")
                                .font(.dsDisplay(17, weight: .regular))
                        }
                        .foregroundColor(Color.dsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            ZStack {
                                isSpinning ? AnyView(Color.dsSecondary) : AnyView(LinearGradient.dsGoldGradient)
                                LinearGradient(colors: [Color.white.opacity(0.08), Color.clear], startPoint: .top, endPoint: .bottom)
                            }
                        )
                        .animation(.easeInOut(duration: 0.2), value: isSpinning)
                    }
                    .disabled(isSpinning)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .background(
            ZStack {
                Color.dsSurface
                LinearGradient(
                    colors: [Color.white.opacity(0.03), Color.clear],
                    startPoint: .top, endPoint: .center
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.dsBorder, lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.6), radius: 50, x: 0, y: 20)
        .padding(.horizontal, 18)
    }

    private func spin() async {
        guard !isSpinning else { return }
        isSpinning = true; showResult = false; selectedCategory = nil

        // Play wheel spin sound
        SoundManager.shared.playWheelSpin()
        
        let total = Double.random(in: 5...9) * 360 + Double.random(in: 0..<360)
        withAnimation(.interpolatingSpring(stiffness: 16, damping: 9)) { rotation += total }

        // Intensive haptic feedback during spin
        Task {
            // Create rhythmic haptic ticks during the spin
            let tickCount = 20 // Number of haptic ticks during spin
            let spinDuration = 3.3
            let tickInterval = spinDuration / Double(tickCount)
            
            for i in 0..<tickCount {
                guard !Task.isCancelled else { return }
                
                // Vary intensity - stronger at the beginning, softer towards the end
                let progress = Double(i) / Double(tickCount)
                if progress < 0.7 {
                    HapticManager.shared.wheelSpinTick()
                } else {
                    HapticManager.shared.soft()
                }
                
                try? await Task.sleep(for: .seconds(tickInterval))
            }
        }

        try? await Task.sleep(for: .seconds(3.3))
        guard !Task.isCancelled else { return }

        // Stop the wheel sound
        SoundManager.shared.stopWheelSpin()
        
        // Normalize rotation to 0-360 range
        let norm  = rotation.truncatingRemainder(dividingBy: 360)
        // Pointer is at -90° in segment coords. Wheel rotates clockwise.
        // Find which segment is at the pointer: -90° - rotation
        let pointerAngle = (-90.0 - norm).truncatingRemainder(dividingBy: 360)
        let adjusted = pointerAngle < 0 ? pointerAngle + 360 : pointerAngle
        let segmentAngle = (adjusted + 90).truncatingRemainder(dividingBy: 360)
        let index = Int(segmentAngle / (360.0 / Double(categories.count))) % categories.count
        selectedCategory = categories[index]

        // Success haptic when wheel lands
        HapticManager.shared.wheelLanded()
        SoundManager.shared.playSelected()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showResult = true; isSpinning = false
        }
    }
}

// MARK: - Wheel Graphic

@MainActor
struct WheelGraphic: View {
    let categories: [QuestionCategory]
    let rotation:   Double

    var body: some View {
        GeometryReader { geo in
            let size    = min(geo.size.width, geo.size.height)
            let center  = CGPoint(x: size / 2, y: size / 2)
            let radius  = size / 2
            let seg     = 360.0 / Double(categories.count)

            ZStack {
                Circle()
                    .fill(Color.dsSurfaceHigh)
                    .overlay(Circle().stroke(Color.dsBorder, lineWidth: 0.8))

                ForEach(Array(categories.enumerated()), id: \.element.id) { i, cat in
                    WheelSegment(
                        startAngle: Angle(degrees: Double(i)     * seg - 90),
                        endAngle:   Angle(degrees: Double(i + 1) * seg - 90),
                        center: center, radius: CGFloat(radius - 1),
                        category: cat, index: i
                    )
                }

                // Spoke lines
                ForEach(0..<categories.count, id: \.self) { i in
                    let angle = Double(i) * seg - 90
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: CGPoint(
                            x: center.x + CGFloat(radius) * CGFloat(cos(angle * .pi / 180)),
                            y: center.y + CGFloat(radius) * CGFloat(sin(angle * .pi / 180))
                        ))
                    }
                    .stroke(Color.dsBackground, lineWidth: 1.2)
                }

                Circle()
                    .stroke(LinearGradient.dsGoldGradient, lineWidth: 1.2)
                    .frame(width: size - 2, height: size - 2)
            }
        }
        .rotationEffect(.degrees(rotation))
        .animation(.interpolatingSpring(stiffness: 16, damping: 9), value: rotation)
    }
}

struct WheelSegment: View {
    let startAngle: Angle
    let endAngle:   Angle
    let center:     CGPoint
    let radius:     CGFloat
    let category:   QuestionCategory
    let index:      Int
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        let mid     = (startAngle.radians + endAngle.radians) / 2
        let labelR  = radius * 0.68
        let labelPos = CGPoint(
            x: center.x + labelR * CGFloat(cos(mid)),
            y: center.y + labelR * CGFloat(sin(mid))
        )

        ZStack {
            Path { p in
                p.move(to: center)
                p.addArc(center: center, radius: radius,
                         startAngle: startAngle, endAngle: endAngle, clockwise: false)
                p.closeSubpath()
            }
            .fill(index % 2 == 0 ? Color.dsSurface : Color.dsSurfaceHigh)

            Image(systemName: category.icon)
                .font(.system(size: horizontalSizeClass == .regular ? 20 : 14, weight: .light))
                .foregroundColor(category.accentColor.opacity(0.9))
                .position(labelPos)
        }
    }
}
