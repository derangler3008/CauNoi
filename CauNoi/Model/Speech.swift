import AVFoundation

/// Sprachausgabe über die Systemstimmen — offline, nichts geht ins Netz.
final class Speech {
    static let shared = Speech()
    private let synth = AVSpeechSynthesizer()

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ text: String, lang: String, slow: Bool = false) {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = currentVoice(lang)
        u.rate = slow ? 0.3 : 0.42
        u.preUtteranceDelay = 0.05
        synth.speak(u)
    }

    /// Vom Nutzer gewählte Stimme — sonst die beste installierte.
    func currentVoice(_ lang: String) -> AVSpeechSynthesisVoice? {
        if let id = UserDefaults.standard.string(forKey: "voice.\(lang)"),
           let v = AVSpeechSynthesisVoice(identifier: id) {
            return v
        }
        return bestVoice(lang)
    }

    /// Alle installierten Stimmen einer Sprache, beste zuerst.
    func voices(for lang: String) -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(lang) }
            .sorted { rank($0) > rank($1) }
    }

    static func qualityLabel(_ v: AVSpeechSynthesisVoice, ui: String) -> String {
        switch v.quality {
        case .premium:  return ui == "de" ? "Premium" : "Cao cấp"
        case .enhanced: return ui == "de" ? "Verbessert" : "Nâng cao"
        default:        return ui == "de" ? "Standard" : "Thường"
        }
    }

    private func bestVoice(_ lang: String) -> AVSpeechSynthesisVoice? {
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(lang) }
        let ranked = candidates.sorted { a, b in rank(a) > rank(b) }
        return ranked.first ?? AVSpeechSynthesisVoice(language: lang)
    }
    private func rank(_ v: AVSpeechSynthesisVoice) -> Int {
        switch v.quality {
        case .premium: return 3
        case .enhanced: return 2
        default: return 1
        }
    }

    var hasVietnamese: Bool {
        AVSpeechSynthesisVoice.speechVoices().contains { $0.language.hasPrefix("vi") }
    }
    var hasGerman: Bool {
        AVSpeechSynthesisVoice.speechVoices().contains { $0.language.hasPrefix("de") }
    }
}
