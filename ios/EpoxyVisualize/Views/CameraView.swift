import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var capturedImage: UIImage?
    @State private var flashEnabled = false

    var body: some View {
        ZStack {
            AppTheme.surfaceDark
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Button {
                        flashEnabled.toggle()
                    } label: {
                        Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title3)
                            .foregroundStyle(flashEnabled ? .yellow : .white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)

                Spacer()

                #if targetEnvironment(simulator)
                cameraPlaceholder
                #else
                if AVCaptureDevice.default(for: .video) != nil {
                    CameraPreviewView(capturedImage: $capturedImage, flashEnabled: flashEnabled, onCapture: {
                        dismiss()
                    })
                } else {
                    cameraPlaceholder
                }
                #endif

                Spacer()

                captureControls
                    .padding(.bottom, 40)
            }
        }
    }

    private var cameraPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.brandRed.opacity(0.6))

            Text("Camera Preview")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Install this app on your device\nvia the Rork App to use the camera.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.surfaceCard)
        .clipShape(.rect(cornerRadius: 20))
        .padding(.horizontal, 24)
    }

    private var captureControls: some View {
        HStack(spacing: 40) {
            Spacer()

            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(AppTheme.brandRed, lineWidth: 4)
                        .frame(width: 76, height: 76)
                    Circle()
                        .fill(AppTheme.brandRed)
                        .frame(width: 62, height: 62)
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: false)

            Spacer()
        }
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    let flashEnabled: Bool
    let onCapture: () -> Void

    func makeUIViewController(context: Context) -> CameraPreviewController {
        CameraPreviewController()
    }

    func updateUIViewController(_ uiViewController: CameraPreviewController, context: Context) {}
}

class CameraPreviewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
}
