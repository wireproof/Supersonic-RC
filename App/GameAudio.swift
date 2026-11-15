import AVFoundation

/// Original audio recovered from the supplied movie. Mixing is provisional.
final class GameAudio {
    private var music: AVAudioPlayer?
    private var engine: AVAudioPlayer?

    init() {
        music = makePlayer("MusicLoop", volume: 0.28)
        engine = makePlayer("CarLoop", volume: 0.3)
        music?.numberOfLoops = -1
        engine?.numberOfLoops = -1
    }
    private func makePlayer(_ name: String, volume: Float) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3"), let p = try? AVAudioPlayer(contentsOf: url) else { return nil }
        p.volume = volume
        p.prepareToPlay()
        return p
    }
    func setPlaying(_ playing: Bool) {
        if playing { music?.play() } else { music?.pause(); engine?.pause() }
    }
    func setAccelerating(_ down: Bool, playing: Bool) {
        if down && playing { engine?.play() } else { engine?.pause() }
    }
}
