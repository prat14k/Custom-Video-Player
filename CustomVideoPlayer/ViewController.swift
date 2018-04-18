//
//  ViewController.swift
//  CustomVideoPlayer
//
//  Created by Prateek Sharma on 17/04/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    
    let url = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
    
    @IBOutlet weak var videoPlayerView : UIView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer(url: URL(string: url)!)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resize
        
        videoPlayerView.layer.insertSublayer(playerLayer, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoPlayerView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player.play()
    }

}

