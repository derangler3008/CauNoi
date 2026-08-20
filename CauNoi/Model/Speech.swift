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
        u.voice = bestVoice(lang)
        u.rate = slow ? 0.3 : 0.42
        u.preUtteranceDelay = 0.05
        synth.speak(u)
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
