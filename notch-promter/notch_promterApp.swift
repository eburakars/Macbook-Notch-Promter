//
//  NotchPromter.swift
//  Tek dosya: App · AppDelegate · Window · View · ViewModel
//  macOS 15 Sequoia+
//  MacBook notch üstünde prompter / yukarı kayan yazı ekranı
//

import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers

// ─────────────────────────────────────────────────────────────────
// MARK: - 1. App Entry Point
// ─────────────────────────────────────────────────────────────────

@main
struct NotchPromterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 2. App Delegate + Menu Bar
// ─────────────────────────────────────────────────────────────────

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindowController: NotchOverlayWindowController?
    var statusItem: NSStatusItem?
    var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()
        setupOverlay()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        statusItem?.button?.image = NSImage(
            systemSymbolName: "text.alignleft",
            accessibilityDescription: "NotchPromter"
        )

        let menu = NSMenu()

        menu.addItem(
            NSMenuItem(
                title: "Ayarlar",
                action: #selector(openSettings),
                keyEquivalent: ","
            )
        )

        menu.addItem(.separator())

        menu.addItem(
            NSMenuItem(
                title: "Yenile",
                action: #selector(refreshContent),
                keyEquivalent: "r"
            )
        )

        menu.addItem(.separator())

        menu.addItem(
            NSMenuItem(
                title: "Çıkış",
                action: #selector(quit),
                keyEquivalent: "q"
            )
        )

        statusItem?.menu = menu
    }

    private func setupOverlay() {
        overlayWindowController = NotchOverlayWindowController()
        overlayWindowController?.showWindow(nil)
    }

    @objc func openSettings() {
        if settingsWindowController == nil {
            let win = NSWindow(
                contentViewController: NSHostingController(
                    rootView: SettingsView()
                )
            )

            win.title = "NotchPromter Ayarlar"
            win.setContentSize(NSSize(width: 460, height: 380))
            win.styleMask = [.titled, .closable]
            win.center()

            settingsWindowController = NSWindowController(window: win)
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController?.showWindow(nil)
    }

    @objc func refreshContent() {
        overlayWindowController?.refresh()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 3. Overlay Window Controller
// ─────────────────────────────────────────────────────────────────

@MainActor
class NotchOverlayWindowController: NSWindowController {
    private let viewModel = TickerViewModel()

    init() {
        let screen = Self.notchScreen() ?? NSScreen.main!

        let popupW: CGFloat = 520
        let popupH: CGFloat = 78

        let menuBarH: CGFloat =
            screen.frame.height -
            screen.visibleFrame.height -
            screen.visibleFrame.origin.y

        let centerX = screen.frame.midX

        let frame = NSRect(
            x: centerX - popupW / 2,
            y: screen.frame.maxY - menuBarH - popupH + menuBarH * 1.12,
            width: popupW,
            height: popupH
        )

        let window = NotchOverlayWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        super.init(window: window)

        window.contentView = NSHostingView(
            rootView: PrompterTickerView(viewModel: viewModel)
        )

        window.orderFrontRegardless()
        viewModel.startFetching()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func refresh() {
        viewModel.fetchContent()
    }

    static func notchScreen() -> NSScreen? {
        NSScreen.screens.first { $0.safeAreaInsets.top > 0 }
        ?? NSScreen.screens.first {
            $0.localizedName.lowercased().contains("built-in")
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 4. Overlay NSWindow
// ─────────────────────────────────────────────────────────────────

class NotchOverlayWindow: NSWindow {
    override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: backing,
            defer: flag
        )

        level = NSWindow.Level(
            rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        isMovable = false
        canHide = false
        hidesOnDeactivate = false

        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary
        ]
    }

    override var canBecomeKey: Bool {
        false
    }

    override var canBecomeMain: Bool {
        false
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 5. Prompter Ticker View
// ─────────────────────────────────────────────────────────────────

struct PrompterTickerView: View {
    @ObservedObject var viewModel: TickerViewModel

    @AppStorage("scrollSpeed") private var scrollSpeed: Double = 5.0
    @AppStorage("fontSize") private var fontSize: Double = 31.0

    var body: some View {
        GeometryReader { geo in
            VerticalPrompterText(
                text: viewModel.displayText,
                speed: scrollSpeed,
                fontSize: fontSize
            )
            .padding(.vertical, 9)
            .padding(.horizontal, 18)
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color.black.opacity(0.96))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.55),
                radius: 18,
                x: 0,
                y: 8
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 6. Yukarı Kayan Gerçek Prompter Text
// ─────────────────────────────────────────────────────────────────

private struct VerticalPrompterText: View {
    let text: String
    let speed: Double
    let fontSize: Double

    @State private var textHeight: CGFloat = 1
    @State private var startTime = Date()

    private var finalText: String {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanText.isEmpty ? "— veri yok —" : cleanText
    }

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let containerWidth: CGFloat = geo.size.width
                let containerHeight: CGFloat = geo.size.height

                let safeTextHeight: CGFloat = max(textHeight, 1)
                let extraGap: CGFloat = 34

                let totalDistance: CGFloat =
                    containerHeight +
                    safeTextHeight +
                    extraGap

                let pixelsPerSecond: CGFloat =
                    max(CGFloat(speed) * 2.5, 9.0)

                let elapsed: TimeInterval =
                    timeline.date.timeIntervalSince(startTime)

                let duration: TimeInterval =
                    max(TimeInterval(totalDistance / pixelsPerSecond), 0.1)

                let progress: Double =
                    elapsed.truncatingRemainder(dividingBy: duration) / duration

                let yOffset: CGFloat =
                    containerHeight - CGFloat(progress) * totalDistance

                Text(finalText)
                    .font(
                        .system(
                            size: CGFloat(fontSize),
                            weight: .heavy,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(Color.white.opacity(0.97))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .frame(width: containerWidth, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(x: 0, y: yOffset)
                    .shadow(
                        color: Color.white.opacity(0.22),
                        radius: 3,
                        x: 0,
                        y: 0
                    )
                    .background(
                        Text(finalText)
                            .font(
                                .system(
                                    size: CGFloat(fontSize),
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .frame(width: containerWidth, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .background(
                                GeometryReader { textGeo in
                                    Color.clear
                                        .onAppear {
                                            textHeight = max(textGeo.size.height, 1)
                                        }
                                        .onChange(of: finalText) { _, _ in
                                            textHeight = max(textGeo.size.height, 1)
                                            startTime = Date()
                                        }
                                        .onChange(of: fontSize) { _, _ in
                                            textHeight = max(textGeo.size.height, 1)
                                            startTime = Date()
                                        }
                                }
                            )
                    )
            }
        }
        .clipped()
        .onAppear {
            startTime = Date()
        }
        .onChange(of: text) { _, _ in
            startTime = Date()
        }
        .onChange(of: speed) { _, _ in
            startTime = Date()
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 7. Settings View
// ─────────────────────────────────────────────────────────────────

struct SettingsView: View {
    @AppStorage("scrollSpeed") private var scrollSpeed: Double = 5.0
    @AppStorage("fontSize") private var fontSize: Double = 31.0
    @AppStorage("refreshInterval") private var refreshInterval: Double = 300

    @State private var source = ContentSource.load()
    @State private var testResult: String?
    @State private var isTesting = false

    var body: some View {
        Form {
            Section("Veri Kaynağı") {
                Picker("Tür", selection: $source.type) {
                    Text("URL").tag(ContentSource.SourceType.url)
                    Text("Dosya").tag(ContentSource.SourceType.file)
                    Text("RSS").tag(ContentSource.SourceType.rss)
                }
                .pickerStyle(.segmented)

                switch source.type {
                case .url, .rss:
                    TextField("URL", text: $source.urlString)
                        .textFieldStyle(.roundedBorder)

                case .file:
                    HStack {
                        TextField("Dosya yolu", text: $source.filePath)
                            .textFieldStyle(.roundedBorder)

                        Button("Seç…") {
                            pickFile()
                        }
                    }
                }
            }

            if source.type == .url {
                Section("JSON Parse") {
                    Picker("Mod", selection: parseModeBinding) {
                        Text("Düz Metin").tag("plain")
                        Text("Satırlar").tag("lines")
                        Text("JSON Path").tag("json")
                    }
                    .pickerStyle(.radioGroup)

                    if case .jsonPath(let p) = source.parseMode {
                        TextField(
                            "JSON yolu örn: items.0.title",
                            text: jsonPathBinding(p)
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }

            Section("Prompter Görünüm") {
                LabeledContent("Yazı Boyutu: \(Int(fontSize))") {
                    Slider(
                        value: $fontSize,
                        in: 22...48,
                        step: 1
                    )
                }

                LabeledContent("Yukarı Kayma Hızı: \(Int(scrollSpeed))") {
                    Slider(
                        value: $scrollSpeed,
                        in: 1...12,
                        step: 1
                    )
                }

                LabeledContent("Yenileme: \(refreshLabel)") {
                    Slider(
                        value: $refreshInterval,
                        in: 30...3600,
                        step: 30
                    )
                }
            }

            Section {
                HStack {
                    Button("Test Et") {
                        testSource()
                    }
                    .disabled(isTesting)

                    Spacer()

                    Button("Kaydet") {
                        save()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let result = testResult {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(
                            result.hasPrefix("✅") ? .green : .red
                        )
                        .lineLimit(4)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 440, minHeight: 360)
    }

    private var refreshLabel: String {
        if refreshInterval < 60 {
            return "\(Int(refreshInterval)) sn"
        } else {
            return "\(Int(refreshInterval / 60)) dk"
        }
    }

    private var parseModeBinding: Binding<String> {
        Binding(
            get: {
                switch source.parseMode {
                case .plainText:
                    return "plain"
                case .jsonPath:
                    return "json"
                case .lines:
                    return "lines"
                }
            },
            set: {
                switch $0 {
                case "json":
                    source.parseMode = .jsonPath("")
                case "lines":
                    source.parseMode = .lines
                default:
                    source.parseMode = .plainText
                }
            }
        )
    }

    private func jsonPathBinding(_ current: String) -> Binding<String> {
        Binding(
            get: {
                current
            },
            set: {
                source.parseMode = .jsonPath($0)
            }
        )
    }

    private func pickFile() {
        let panel = NSOpenPanel()

        panel.allowedContentTypes = [
            .plainText,
            .json,
            .xml
        ]

        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            source.filePath = panel.url?.path ?? ""
        }
    }

    private func testSource() {
        isTesting = true
        testResult = nil

        let currentSource = source

        Task {
            do {
                let text = try await currentSource.fetch()
                let preview = "✅ \(String(text.prefix(160)))…"

                await MainActor.run {
                    testResult = preview
                    isTesting = false
                }
            } catch {
                let message = "❌ \(error.localizedDescription)"

                await MainActor.run {
                    testResult = message
                    isTesting = false
                }
            }
        }
    }

    private func save() {
        source.save()

        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil
        )
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 8. TickerViewModel
// ─────────────────────────────────────────────────────────────────

@MainActor
class TickerViewModel: ObservableObject {
    @Published var displayText: String = "Yükleniyor..."
    @Published var isLoading = false
    @Published var lastError: String?

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var refreshInterval: TimeInterval {
        let v = UserDefaults.standard.double(
            forKey: "refreshInterval"
        )

        return v > 0 ? v : 300
    }

    func startFetching() {
        fetchContent()
        scheduleTimer()

        NotificationCenter.default.publisher(
            for: .settingsChanged
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.fetchContent()
            self?.scheduleTimer()
        }
        .store(in: &cancellables)
    }

    func scheduleTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(
            withTimeInterval: refreshInterval,
            repeats: true
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.fetchContent()
            }
        }
    }

    func fetchContent() {
        let currentSource = ContentSource.load()

        isLoading = true

        Task {
            do {
                let raw = try await currentSource.fetch()

                await MainActor.run {
                    let processed = self.process(
                        raw,
                        mode: currentSource.parseMode
                    )

                    self.displayText = processed.isEmpty
                        ? "— veri yok —"
                        : processed

                    self.lastError = nil
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription

                    if self.displayText == "Yükleniyor..." {
                        self.displayText = "⚠️ \(error.localizedDescription)"
                    }

                    self.isLoading = false
                }
            }
        }
    }

    private func process(
        _ raw: String,
        mode: ContentSource.ParseMode
    ) -> String {
        switch mode {
        case .plainText:
            return raw.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        case .lines:
            return raw
                .components(separatedBy: .newlines)
                .map {
                    $0.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                }
                .filter {
                    !$0.isEmpty
                }
                .joined(separator: "\n\n")

        case .jsonPath(let path):
            guard let data = raw.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(
                    with: data
                  ) as? [String: Any] else {
                return raw.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }

            var current: Any = json

            for key in path.components(separatedBy: ".") {
                if let dict = current as? [String: Any],
                   let value = dict[key] {
                    current = value
                } else if let array = current as? [Any],
                          let index = Int(key),
                          index < array.count {
                    current = array[index]
                } else {
                    return raw.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                }
            }

            if let string = current as? String {
                return string
            }

            if let array = current as? [Any] {
                return array
                    .compactMap {
                        $0 as? String
                    }
                    .joined(separator: "\n\n")
            }

            return raw.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 9. ContentSource
// ─────────────────────────────────────────────────────────────────

struct ContentSource: Codable {
    enum SourceType: String, Codable {
        case url
        case file
        case rss
    }

    enum ParseMode: Codable {
        case plainText
        case jsonPath(String)
        case lines

        enum CodingKeys: String, CodingKey {
            case type
            case path
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(
                keyedBy: CodingKeys.self
            )

            let type = try container.decode(
                String.self,
                forKey: .type
            )

            switch type {
            case "jsonPath":
                let path = try container.decode(
                    String.self,
                    forKey: .path
                )

                self = .jsonPath(path)

            case "lines":
                self = .lines

            default:
                self = .plainText
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(
                keyedBy: CodingKeys.self
            )

            switch self {
            case .plainText:
                try container.encode(
                    "plainText",
                    forKey: .type
                )

            case .jsonPath(let path):
                try container.encode(
                    "jsonPath",
                    forKey: .type
                )

                try container.encode(
                    path,
                    forKey: .path
                )

            case .lines:
                try container.encode(
                    "lines",
                    forKey: .type
                )
            }
        }
    }

    var type: SourceType = .file
    var urlString: String = ""
    var filePath: String = ""
    var parseMode: ParseMode = .lines
    var customHeaders: [String: String] = [:]

    static func defaultTXTPath() -> String? {
        let fm = FileManager.default

        let candidates: [String] = [
            Bundle.main.bundleURL
                .deletingLastPathComponent()
                .appendingPathComponent("ticker.txt")
                .path,

            Bundle.main.url(
                forResource: "ticker",
                withExtension: "txt"
            )?.path ?? "",

            (fm.currentDirectoryPath as NSString)
                .appendingPathComponent("ticker.txt"),

            fm.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first?
                .appendingPathComponent("ticker.txt")
                .path ?? ""
        ]

        return candidates.first {
            !$0.isEmpty && fm.fileExists(atPath: $0)
        }
    }

    static func load() -> ContentSource {
        if let data = UserDefaults.standard.data(
            forKey: "contentSource"
        ),
           let saved = try? JSONDecoder().decode(
            ContentSource.self,
            from: data
           ) {
            return saved
        }

        var source = ContentSource()

        if let path = defaultTXTPath() {
            source.filePath = path
        }

        return source
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(
                data,
                forKey: "contentSource"
            )
        }
    }

    func fetch() async throws -> String {
        switch type {
        case .url:
            return try await fetchURL(urlString)

        case .file:
            let path = filePath.isEmpty
                ? (Self.defaultTXTPath() ?? "")
                : filePath

            guard !path.isEmpty else {
                return "ticker.txt bulunamadı — uygulama yanına bir ticker.txt koyun"
            }

            return try String(
                contentsOfFile: path,
                encoding: .utf8
            )

        case .rss:
            let xml = try await fetchURL(urlString)
            return parseRSS(xml)
        }
    }

    private func fetchURL(_ urlStr: String) async throws -> String {
        guard let url = URL(string: urlStr) else {
            throw Err.invalidURL
        }

        var request = URLRequest(
            url: url,
            timeoutInterval: 15
        )

        customHeaders.forEach {
            request.setValue(
                $1,
                forHTTPHeaderField: $0
            )
        }

        let (data, _) = try await URLSession.shared.data(
            for: request
        )

        return String(data: data, encoding: .utf8) ?? ""
    }

    private func parseRSS(_ xml: String) -> String {
        xml
            .components(separatedBy: "<title>")
            .dropFirst()
            .dropFirst()
            .prefix(10)
            .compactMap { chunk -> String? in
                guard let end = chunk.range(of: "</title>") else {
                    return nil
                }

                return String(chunk[..<end.lowerBound])
                    .replacingOccurrences(
                        of: "<![CDATA[",
                        with: ""
                    )
                    .replacingOccurrences(
                        of: "]]>",
                        with: ""
                    )
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
            }
            .joined(separator: "\n\n")
    }

    enum Err: LocalizedError {
        case invalidURL

        var errorDescription: String? {
            "Geçersiz URL"
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - 10. Notification
// ─────────────────────────────────────────────────────────────────

extension Notification.Name {
    static let settingsChanged = Notification.Name(
        "NotchPromter.settingsChanged"
    )
}
