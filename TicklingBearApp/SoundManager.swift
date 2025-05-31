import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        // Configure audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playGiggle() {
        // Generate a random giggle sound programmatically
        // This creates a simple giggle-like sound using system sounds
        AudioServicesPlaySystemSound(1016) // This is a gentle notification sound
        
        // For a more custom approach, we could generate tones
        generateGiggleSound()
    }
    
    private func generateGiggleSound() {
        // Create a simple giggle pattern with varying frequencies
        let frequencies: [Float] = [400, 500, 450, 550, 480, 520]
        
        DispatchQueue.global(qos: .background).async {
            for (index, frequency) in frequencies.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    AudioServicesPlaySystemSound(1016)
                }
            }
        }
    }
    
    func playRandomGiggle() {
        let giggles = [1016, 1013, 1014, 1015] // Different system sounds
        let randomGiggle = giggles.randomElement() ?? 1016
        AudioServicesPlaySystemSound(SystemSoundID(randomGiggle))
    }
}
