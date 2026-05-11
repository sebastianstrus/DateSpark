import SwiftUI

// MARK: - Shareable Question Card

/// A styled view designed to be rendered as an image and shared
@MainActor
struct ShareableQuestionView: View {
    let question: Question
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.dsSurface)
            
            // Category gradient wash
            LinearGradient(
                colors: [question.category.accentColor.opacity(0.12), Color.clear],
                startPoint: .topLeading,
                endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Left accent bar
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(
                    colors: [question.category.accentColor, question.category.accentColor.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 5)
                .padding(.vertical, 48)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack(alignment: .leading, spacing: 0) {
                // Top branding section
                HStack(spacing: 12) {
                    Image("spark_clear")
                        .resizable() // Makes the image allow resizing
                        .scaledToFit() // Keeps the aspect ratio intact
                        .frame(width: 28, height: 28)
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                    
                    Text("DateSpark")
                        .font(.dsDisplay(20, weight: .light))
                        .foregroundStyle(LinearGradient.dsGoldGradient)
                    
                    Spacer()
                }
                .padding(.top, 36)
                .padding(.horizontal, 36)
                
                // Category and depth tags
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(question.category.accentColor)
                            .frame(width: 6, height: 6)
                        Text(question.category.localizedName)
                            .font(.dsLabel(10))
                            .tracking(2.5)
                            .foregroundColor(question.category.accentColor)
                            .textCase(.uppercase)
                    }
                    
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(question.depth.color)
                            .frame(width: 16, height: 2)
                        Text(question.depth.localizedName)
                            .font(.dsLabel(9))
                            .tracking(2)
                            .foregroundColor(question.depth.color.opacity(0.85))
                            .textCase(.uppercase)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 36)
                
                // Divider
                LinearGradient.dsGoldGradient
                    .frame(height: 0.8)
                    .opacity(0.25)
                    .padding(.horizontal, 36)
                    .padding(.top, 20)
                
                // Question text - centered content
                Text(question.text)
                    .font(.dsDisplay(42, weight: .light))
                    .foregroundColor(Color.dsPrimary)
                    .lineSpacing(9)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 36)
                    .padding(.top, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                // Bottom section
                VStack(alignment: .leading, spacing: 12) {
                    LinearGradient.dsGoldGradient
                        .frame(height: 0.8)
                        .opacity(0.25)
                    
                    Text("Share meaningful moments")
                        .font(.dsLabel(11, weight: .regular))
                        .foregroundColor(Color.dsSecondary)
                        .tracking(1)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 36)
            }
        }
        .frame(width: 600, height: 800)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.2
                )
        )
    }
}

// MARK: - Question Sharing Helper

@MainActor
struct QuestionSharingHelper {
    /// Generates a UIImage from a Question
    static func generateImage(for question: Question) -> UIImage? {
        let view = ShareableQuestionView(question: question)
        
        // Create renderer with explicit proposedSize
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        
        // Render the image
        let image = renderer.uiImage
        return image
    }
}

// MARK: - UIActivityViewController Wrapper

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ShareSheet Helper Extension

extension View {
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        sheet(isPresented: isPresented) {
            if !items.isEmpty {
                ActivityViewController(activityItems: items)
            }
        }
    }
}
