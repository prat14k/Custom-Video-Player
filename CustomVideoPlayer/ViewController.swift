//
//  ViewController.swift
//  CustomVideoPlayer
//
//  Created by Prateek Sharma on 17/04/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import AVFoundation



enum VideoState {
    case playing
    case paused
    case notPlaying
}


class ViewController: UIViewController {

    var videoState : VideoState = .notPlaying
    
    let url = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
    
    @IBOutlet weak var videoPlayerView : UIView!
    @IBOutlet weak var videoPlayPauseBarBtn : UIBarButtonItem!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer(url: URL(string: url)!)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resize
        
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new , .initial], context: nil)
        
        addSliderUpdater()
        
        videoPlayerView.layer.insertSublayer(playerLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoPlayerView.bounds
    }
    
    @objc func videoFinishedPlaying(_ notification : Notification) {
        videoState = .notPlaying
        videoPlayPauseBarBtn.title = "▶︎"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFinishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        player.currentItem?.removeObserver(self, forKeyPath: "duration")
    }
    
    @IBAction func rewindAction(_ sender: UIBarButtonItem) {
        
        let currentPlayerCMTime = player.currentTime()
        let currentTime = CMTimeGetSeconds(currentPlayerCMTime)
        
        if (currentTime - 5.0) >= 0 {
            player.seek(to: CMTime(seconds: (currentTime - 5.0), preferredTimescale: currentPlayerCMTime.timescale))
            player.play()
        }
        
    }
    
    @IBAction func playPauseAction(_ sender: UIBarButtonItem!) {
        
        switch videoState {
        case .notPlaying:
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            fallthrough
        case .paused:
            player.play()
            videoState = .playing
            videoPlayPauseBarBtn.title = "||"
        case .playing:
            player.pause()
            videoState = .paused
            videoPlayPauseBarBtn.title = "▶︎"
        }
        
    }
    
    @IBAction func fastForwardAction(_ sender: UIBarButtonItem) {
        
        guard let duration = player.currentItem?.duration else { return }
        
        let currentPlayerCMTime = player.currentTime()
        let currentTime = CMTimeGetSeconds(currentPlayerCMTime)
        
        if (currentTime + 5.0) < CMTimeGetSeconds(duration) {
            player.seek(to: CMTime(seconds: (currentTime + 5.0), preferredTimescale: currentPlayerCMTime.timescale))
        }

    }
    
    @IBAction func slideToSeekPosition(_ sender : UISlider) {
        guard let currentItem = player.currentItem else { return }
        player.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: currentItem.duration.timescale))
    }
    
    
}


extension ViewController {
    
    private func addSliderUpdater(){
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.global(qos: .background)) { [weak self] (currentTime) in
            guard let curreentItem = self?.player.currentItem else { return }
            DispatchQueue.main.async {
                self?.durationSlider.value = Float(curreentItem.currentTime().seconds)
            }
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration" , let duration = player.currentItem?.duration.seconds , duration > 0.0 {
            self.durationSlider.maximumValue = Float(duration)
            self.durationSlider.minimumValue = 0.0
            self.durationSlider.value = 0.0
            self.durationLabel.text = secondsToString(duration)
        }
    }
    
    private func secondsToString(_ duration : Float64) -> String {
        
        let hrs = Int(duration/3600)
        let min = Int(duration/60) % 60
        let sec = Int(duration) % 60
        
        if hrs > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hrs,min,sec])
        }
        else{
            return String(format: "%02i:%02i", arguments: [min,sec])
        }

    }
    
}

