//
//  ContentView.swift
//  VideoPlayBack
//
//  Created by Brian Ortiz on 2023-03-31.
//

import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    
    let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    let player = AVPlayer()
    
    @State private var isPlaying = false
    @State private var playbackProgress: Float = 0
    let skipInterval: Double = 10
    
    
    var body: some View {
        
        VStack {
            
            VideoPlayer(player: player)
                .onAppear {
                    player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                }
                .frame(height: 800)
            
            ProgressView(value: playbackProgress)
                .padding()
            
            HStack {
                Button(action: {
                    skipBackward()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title3)
                }
                
                Button(action: {
                    isPlaying.toggle()
                    if isPlaying {
                        player.play()
                    } else {
                        player.pause()
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                
                Button(action: {
                    skipForward()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title3)
                }
            }
            
        }.onReceive(player.publisher(for: \.currentItem)) { item in
            guard let item = item else { return }
            player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, preferredTimescale: 1), queue: DispatchQueue.main) { time in
                let currentTime = CMTimeGetSeconds(time)
                let duration = CMTimeGetSeconds(item.duration)
                playbackProgress = Float(currentTime / duration)
                
                if playbackProgress == 1.0 {
                    player.seek(to: .zero)
                    player.pause()
                    player.play()
                }
                
            }
        }
        
    }
    
    func skipBackward() {
        guard let currentItem = player.currentItem else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(0, currentTime - skipInterval)
        player.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: currentItem.currentTime().timescale))
    }
    
    func skipForward() {
        guard let currentItem = player.currentItem else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let duration = CMTimeGetSeconds(currentItem.duration)
        let newTime = min(duration, currentTime + skipInterval)
        player.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: currentItem.currentTime().timescale))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


