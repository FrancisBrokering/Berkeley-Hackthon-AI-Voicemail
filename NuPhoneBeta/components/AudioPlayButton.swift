import SwiftUI
import AVFoundation

struct AudioPlayButton: View {
//    private var audioURL: URL
    private var callId: String
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 0
    @State private var timeObserver: Any?
    @State private var isLoading: Bool = true
    
    // For slider and time display
    var currentTimeString: String {
        return formatTime(seconds: currentTime)
    }
    
    var totalTimeString: String {
        return formatTime(seconds: totalTime)
    }
    
//    init(audioURL: URL) {
//        self.audioURL = audioURL
//    }
    
    init(callId: String) {
        self.callId = callId
    }
    
    var body: some View {
        HStack {
            if self.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 30, height: 30) 
                    .background(
                        Circle()
                            .fill(Color("AccentColor"))
                            .frame(width: 30, height: 30)
                    )
                    .disableWithOpacity(true)
            }
            else {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30) // Ensure Button has the same frame
                }
            }
            Slider(value: $currentTime, in: 0...totalTime, onEditingChanged: sliderChanged)
                .onAppear {
                    let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
                    UISlider.appearance()
                        .setThumbImage(UIImage(systemName: "circle.fill",
                                               withConfiguration: progressCircleConfig), for: .normal)
                }
            Text("\(currentTimeString)/\(totalTimeString)")
                .font(.footnote)
            //                        .foregroundColor(Color.gray)
            
        }
        //        .background(.gray)
        .padding(20)
        .background(.ultraThinMaterial, in:
                        RoundedRectangle(cornerRadius: 20, style: .continuous))
        .clipShape(Capsule())
        .onAppear {
            self.setupAudio(callId: callId)
        }
        .onDisappear {
            if let observer = timeObserver {
                player?.removeTimeObserver(observer)
                timeObserver = nil
            }
            player?.pause()
            isPlaying = false
            currentTime = 0
            player?.seek(to: .zero)
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session for playback: \(error)")
        }
    }

    
    private func setupAudio(callId: String) {
        setupAudioSession()
        //        self.player = AVPlayer(url: audioURL)
        DispatchQueue.global(qos: .userInitiated).async {
            if let subAccountApiKey = UserManager.shared.subAccountApiKey {
                self.isLoading = true
                print("SUBACCOUNT")
                let headers: [String: String] = [
                    "X-API-KEY": subAccountApiKey
                ]
                CallsAPI.getAudioUrl(callId: callId) { audioURL in
                    if audioURL != nil {
                            let asset = AVURLAsset(url: audioURL!)
                            print("ASSETS", asset)
                            let playerItem = AVPlayerItem(asset: asset)
                            print("Player Item", playerItem)
                            DispatchQueue.main.async {
                            self.player = AVPlayer(playerItem: playerItem)
                            self.totalTime = player?.currentItem?.asset.duration.seconds ?? 0
                            
                            // Add Periodic Time Observer
                            let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                            timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                                self.currentTime = time.seconds
                            }
                            
                            // Notification for when the audio finishes playing
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                                self.isPlaying = false
                                self.player?.seek(to: .zero)
                                self.currentTime = 0
                            }
                                self.isLoading = false
                        }
                    } else {
                        self.isLoading = false
                    }
                }
            }
            else {
                self.isLoading = false
            }
        }
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    private func sliderChanged(editingStarted: Bool) {
        if editingStarted {
            // If the user starts dragging the slider, pause the player to allow smooth seeking.
            if isPlaying {
                player?.pause()
            }
        } else {
            // Seek to the new time once the user stops dragging the slider.
            let newTime = CMTime(seconds: currentTime, preferredTimescale: 600)
            player?.seek(to: newTime) { _ in
                // Only play if the player was playing before user started dragging the slider.
                if self.isPlaying {
                    self.player?.play()
                }
            }
        }
    }
    
    private func downloadAudio() {
        // Implement audio download functionality here
    }
    
    private func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = seconds >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        return formatter.string(from: TimeInterval(seconds)) ?? "00:00"
    }
}

