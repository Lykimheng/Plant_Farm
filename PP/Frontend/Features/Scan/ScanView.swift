//
//  ScanView.swift
//  PP
//
//  Created by Ly Kimheng on 26/12/25.
//

import AVFoundation
import SwiftUI

struct ScanView: View {
    @StateObject private var camera = CameraViewModel()
    @StateObject private var permission = CameraPermissionManager()
    @StateObject private var viewModel = ScanViewModel()
    @EnvironmentObject private var catalog: PlantsStore
    @EnvironmentObject private var toast: ToastCenter
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var pickedImage: UIImage?
    @State private var showPhotoLibrary = false
    @State private var isAnimatingScanLine = false
    @State private var resultDetent: PresentationDetent = .scanSummary

    /// The scan window never grows past this, and shrinks below it when space is short.
    private var maxFrameSide: CGFloat { horizontalSizeClass == .regular ? 400 : 280 }

    /// A phone on its side: too short to stack hint, window and controls.
    private var isShortScreen: Bool { verticalSizeClass == .compact }

    var body: some View {
        ZStack {
            if permission.isCameraAuthorized {
                CameraPreview(session: camera.session, isRunning: camera.isRunning)
                    .ignoresSafeArea()
            } else {
                Theme.textPrimary.opacity(0.9).ignoresSafeArea()
            }

            if permission.isCameraAuthorized {
                
                scannerOverlay
            } else {
                permissionPrompt
            }
        }
        .navigationTitle("Identify a plant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await permission.requestCamera()
            if permission.isCameraAuthorized { camera.start() }
            // The result sheet links into the shop, so have the catalog ready.
            await catalog.loadIfNeeded()
        }
        .onDisappear { camera.stop() }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(selectedImage: $pickedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $viewModel.isShowingResult, onDismiss: { resultDetent = .scanSummary }) {
            ScanResultSheet(viewModel: viewModel, detent: $resultDetent)
                // the tab bar's toast sits underneath this sheet
                .toast(center: toast)
                .presentationDetents([.scanSummary, .large], selection: $resultDetent)
                .presentationDragIndicator(.visible)
        }
        .onChange(of: pickedImage) { _, image in
            guard let image else { return }
            pickedImage = nil   // so picking the same photo twice still triggers
            Task { await viewModel.identify(image) }
        }
    }

    private func capture() {
        Task {
            if let image = await camera.capturePhoto() {
                await viewModel.identify(image)
            } else {
                toast.show("Couldn't take a photo. Try again or pick one from your library.")
            }
        }
    }

    // MARK: - Overlay

    private var scannerOverlay: some View {
        Group {
            if isShortScreen {
                // controls move to a column at the side, like the Camera app
                HStack(spacing: Theme.Spacing.lg) {
                    VStack(spacing: Theme.Spacing.md) {
                        hint
                        scanWindow
                    }
                    .padding(.vertical, Theme.Spacing.md)

                    controls(vertical: true)
                }
                .padding(.horizontal, Theme.Spacing.lg)
            } else {
                VStack(spacing: Theme.Spacing.lg) {
                    hint
                        .padding(.top, Theme.Spacing.xl)
                    scanWindow
                    controls(vertical: false)
                        .padding(.bottom, Theme.Spacing.xl)
                }
                .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        // the dimmed surround is cut out wherever the layout put the window
        .backgroundPreferenceValue(ScanWindowAnchorKey.self) { anchor in
            GeometryReader { proxy in
                dimming(around: anchor.map { proxy[$0] })
            }
            .ignoresSafeArea()
        }
    }

    private var hint: some View {
        Text("Center the plant inside the frame")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(.ultraThinMaterial, in: Capsule())
    }

    /// Takes whatever room is left between the hint and the controls, as a square.
    private var scanWindow: some View {
        ScanFrame()
            .overlay { scanLine }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
            .aspectRatio(1, contentMode: .fit)
            .anchorPreference(key: ScanWindowAnchorKey.self, value: .bounds) { $0 }
            .frame(maxWidth: maxFrameSide, maxHeight: maxFrameSide)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func dimming(around window: CGRect?) -> some View {
        Color.black.opacity(0.45)
            .mask {
                ZStack {
                    Rectangle()
                    if let window {
                        RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                            .frame(width: window.width, height: window.height)
                            .position(x: window.midX, y: window.midY)
                            .blendMode(.destinationOut)
                    }
                }
                .compositingGroup()
            }
    }

    private var scanLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, Theme.brandAccent, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2.5)
            // sweeps edge to edge whatever size the window ends up
            .frame(maxHeight: .infinity, alignment: isAnimatingScanLine ? .bottom : .top)
            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isAnimatingScanLine)
            .onAppear { isAnimatingScanLine = true }
    }

    private func controls(vertical: Bool) -> some View {
        // the side column drops the captions so it fits a landscape phone's height
        let layout = vertical
            ? AnyLayout(VStackLayout(spacing: Theme.Spacing.lg))
            : AnyLayout(HStackLayout(alignment: .top, spacing: Theme.Spacing.xxl))

        return layout {
            controlButton(
                icon: camera.isFlashOn ? Icons.flashOn : Icons.flashOff,
                label: "Flash",
                showsLabel: !vertical,
                isActive: camera.isFlashOn
            ) {
                camera.toggleFlash()
            }

            shutterButton(showsLabel: !vertical)

            controlButton(icon: Icons.photoLibrary, label: "Photos", showsLabel: !vertical, isActive: false) {
                Task {
                    if await permission.requestPhotoLibrary() {
                        showPhotoLibrary = true
                    }
                }
            }
        }
    }

    private func shutterButton(showsLabel: Bool) -> some View {
        Button(action: capture) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 4)
                        .frame(width: 76, height: 76)
                    Circle()
                        .fill(camera.isCapturing ? Theme.brandAccent.opacity(0.6) : .white)
                        .frame(width: 62, height: 62)
                    Image(systemName: Icons.shutter)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                }
                if showsLabel {
                    Text("Identify")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .buttonStyle(.pressable)
        .disabled(!camera.isRunning || camera.isCapturing)
        .opacity(camera.isRunning ? 1 : 0.5)
        .accessibilityLabel("Take a photo to identify the plant")
        .offset(y: showsLabel ? -8 : 0)
    }

    private func controlButton(
        icon: String,
        label: String,
        showsLabel: Bool,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isActive ? Theme.brandAccent : .white)
                    .frame(width: 52, height: 52)
                    .background(.ultraThinMaterial, in: Circle())
                if showsLabel {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(label)
    }

    private var permissionPrompt: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: Icons.camera)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.white.opacity(0.8))

            Text(permission.isCameraDenied ? "Camera access is off" : "Camera access needed")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Text("Allow the camera so you can point it at a plant to identify it. You can also pick a photo instead.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xxl)

            VStack(spacing: Theme.Spacing.md) {
                if permission.isCameraDenied {
                    Button("Open Settings") { permission.openSettings() }
                        .buttonStyle(PrimaryButtonStyle(fullWidth: false))
                } else {
                    Button("Allow camera") {
                        Task {
                            if await permission.requestCamera() { camera.start() }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(fullWidth: false))
                }

                Button("Choose a photo") {
                    Task {
                        if await permission.requestPhotoLibrary() { showPhotoLibrary = true }
                    }
                }
                .buttonStyle(SecondaryButtonStyle(fullWidth: false, tint: .white))
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .scrollableWhenNeeded()
    }
}

// MARK: - Frame corners

private struct ScanWindowAnchorKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

private struct ScanFrame: View {
    private let cornerLength: CGFloat = 26
    private let thickness: CGFloat = 4

    var body: some View {
        ZStack {
            corner.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            corner.rotationEffect(.degrees(90))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            corner.rotationEffect(.degrees(180))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            corner.rotationEffect(.degrees(270))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .accessibilityHidden(true)
    }

    private var corner: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: cornerLength))
            path.addLine(to: .zero)
            path.addLine(to: CGPoint(x: cornerLength, y: 0))
        }
        .stroke(Theme.brandAccent, style: StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round))
        .frame(width: cornerLength, height: cornerLength)
    }
}

// MARK: - Results

private struct ScanResultSheet: View {
    @ObservedObject var viewModel: ScanViewModel
    @Binding var detent: PresentationDetent

    @EnvironmentObject private var catalog: PlantsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    @State private var path: [PlantListing] = []
    @State private var chosen: PlantPrediction?

    /// The candidate being shown: the model's best guess unless the user picked another.
    private var current: PlantPrediction? {
        chosen.flatMap { pick in viewModel.predictions.first { $0.id == pick.id } } ?? viewModel.bestMatch
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    photo
                    content
                }
                .padding(Theme.Spacing.lg)
                .readableWidth(Theme.Layout.wide)
            }
            .background(Theme.background)
            .navigationTitle("Scan result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(for: PlantListing.self) { listing in
                PlantDetailView(listing: listing)
            }
        }
        // A product page needs the full sheet; drop back when the user returns.
        .onChange(of: path) { _, path in
            detent = path.isEmpty ? .scanSummary : .large
        }
        .onChange(of: viewModel.predictions) { _, _ in chosen = nil }
    }

    // MARK: Pieces

    @ViewBuilder
    private var photo: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous))
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isIdentifying {
            ProgressView("Identifying…")
                .tint(Theme.brand)
                .foregroundStyle(Theme.textSecondary)
                .padding(.vertical, Theme.Spacing.xxl)
        } else if let message = viewModel.errorMessage {
            EmptyStateView(
                icon: Icons.leaf,
                title: "Couldn't identify this photo",
                message: message,
                actionTitle: "Try again",
                action: { Task { await viewModel.retry() } }
            )
        } else if let current {
            matchCard(for: current)
            if viewModel.predictions.count > 1 { alternatives(besides: current) }
            if let verdict = viewModel.healthVerdict { healthCard(for: verdict) }
            careCard(for: current.species)
            shopSection(for: current.species)
        } else {
            EmptyStateView(
                icon: Icons.leaf,
                title: "No plant recognised",
                message: "Try a closer photo of a single plant in good light."
            )
        }
    }

    private func matchCard(for prediction: PlantPrediction) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Label { Text(headline(for: prediction)) } icon: { Image(systemName: Icons.identified) }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(prediction.certainty == .low ? Theme.warning : Theme.brand)

            Text(prediction.species.displayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text(prediction.species.scientificName)
                .font(.system(size: 13))
                .italic()
                .foregroundStyle(Theme.textSecondary)

            ConfidenceBar(prediction: prediction)
                .padding(.top, Theme.Spacing.xs)

            if prediction.certainty == .low {
                Text("Fill the frame with one plant in good light for a clearer answer.")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }

    private func headline(for prediction: PlantPrediction) -> LocalizedStringResource {
        switch prediction.certainty {
        case .high:   return "Looks like a"
        case .likely: return "Probably a"
        case .low:    return "Not sure — maybe a"
        }
    }

    private func alternatives(besides current: PlantPrediction) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Not it? It could also be")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(viewModel.predictions.filter { $0.id != current.id }) { prediction in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { chosen = prediction }
                    } label: {
                        HStack(spacing: 5) {
                            Text(prediction.species.displayName)
                            Text(prediction.percentText).foregroundStyle(Theme.textTertiary)
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.surface, in: Capsule())
                        .overlay(Capsule().strokeBorder(Theme.separator, lineWidth: 0.7))
                    }
                    .buttonStyle(.pressable)
                    .accessibilityLabel(Text("Show \(Text(prediction.species.displayName)), \(prediction.percentText)"))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func healthCard(for verdict: HealthPrediction) -> some View {
        let isHealthy = verdict.symptom == .healthy
        let isUnsure = verdict.confidence < 0.45
        let tint = isHealthy ? Theme.success : Theme.warning

        return VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Label("Health check", systemImage: Icons.health)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: isHealthy ? Icons.verified : Icons.warning)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)

                VStack(alignment: .leading, spacing: 2) {
                    healthTitle(for: verdict, isHealthy: isHealthy, isUnsure: isUnsure)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(verdict.percentText) match")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                        .monospacedDigit()
                }
            }

            if !isHealthy {
                healthRow(title: "Usually means", detail: verdict.symptom.likelyCause)
                healthRow(title: "What to do", detail: verdict.symptom.whatToDo)
            } else {
                Text(verdict.symptom.likelyCause)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            let others = viewModel.health.dropFirst().prefix(2).filter { $0.confidence >= 0.15 }
            if !others.isEmpty {
                Text("Also possible: \(others.map { "\(lowercasedName(of: $0.symptom)) \($0.percentText)" }.joined(separator: ", "))")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
    
    private func lowercasedName(of symptom: PlantSymptom) -> String {
        symptom.displayName.string(in: locale).lowercased(with: locale)
    }

    private func healthTitle(for verdict: HealthPrediction, isHealthy: Bool, isUnsure: Bool) -> Text {
        if isHealthy { return Text(verdict.symptom.displayName) }
        let name = lowercasedName(of: verdict.symptom)
        return isUnsure ? Text("Might be showing: \(name)") : Text("Possible issue: \(name)")
    }

    private func healthRow(title: LocalizedStringResource, detail: LocalizedStringResource) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textTertiary)
            Text(detail)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func careCard(for species: PlantSpecies) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Caring for a \(Text(species.displayName))")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)

            careRow(icon: Icons.sun, title: "Light", detail: species.light)
            careRow(icon: Icons.waterFilled, title: "Water", detail: species.water)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private func careRow(icon: String, title: LocalizedStringResource, detail: LocalizedStringResource) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.brand)
                .frame(width: 30, height: 30)
                .background(Theme.brandTint, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textTertiary)
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func shopSection(for species: PlantSpecies) -> some View {
        let matches = catalog.listings(for: catalog.plants(matching: species))

        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            if matches.isEmpty {
                Text("You might also like")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text("We don't have \(Text(species.displayName)) in the shop right now — here are some popular picks instead.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                grid(of: catalog.listings(for: Array(fallbackPlants.prefix(4))))
            } else {
                Text("In our shop")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                grid(of: matches)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Theme.Spacing.sm)
    }

    private var fallbackPlants: [PlantModel] {
        catalog.popularPlants.isEmpty ? catalog.plants : catalog.popularPlants
    }

    @ViewBuilder
    private func grid(of listings: [PlantListing]) -> some View {
        if listings.isEmpty {
            EmptyStateView(
                icon: Icons.bag,
                title: "Shop unavailable",
                message: "Open the Home tab once so the catalog is loaded."
            )
        } else {
            LazyVGrid(columns: .plantGrid, spacing: Theme.Spacing.lg) {
                ForEach(listings) { listing in
                    PlantLink(listing: listing)
                }
            }
        }
    }
}

/// Half the screen on most phones, but never so short that a small phone (iPhone SE)
/// hides the match card below the photo.
nonisolated private struct ScanSummaryDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        min(max(context.maxDetentValue * 0.5, 440), context.maxDetentValue)
    }
}

private extension PresentationDetent {
    static var scanSummary: PresentationDetent { .custom(ScanSummaryDetent.self) }
}

private struct ConfidenceBar: View {
    let prediction: PlantPrediction

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.surfaceAlt)
                    Capsule()
                        .fill(prediction.certainty == .low ? Theme.warning : Theme.brand)
                        .frame(width: proxy.size.width * prediction.confidence)
                }
            }
            .frame(height: 8)

            Text("\(prediction.percentText) match")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(prediction.percentText) match")
    }
}

#Preview {
    NavigationStack {
        ScanView()
            .environmentObject(PlantsStore())
            .environmentObject(CartStore())
            .environmentObject(WishlistStore())
            .environmentObject(UserStore())
            .environmentObject(ToastCenter())
    }
}
