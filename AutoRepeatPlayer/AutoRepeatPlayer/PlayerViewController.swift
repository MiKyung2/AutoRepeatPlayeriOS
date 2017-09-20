
//
//  PlayerViewController.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 5. 31..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AudioKit

class PlayerViewController: UIViewController, CurrentPlayListDelegate,EZAudioFileDelegate, UIScrollViewDelegate {
    let defaults = UserDefaults.standard
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager ()

    var albums:[AlbumInfo]?
    var player:MP3Player?
    var timer:Timer?
    var graphTimer:Timer?
    var currentTrackIndex:Int = -1

    var secPerPosition = 25
    var subSecPerPosition = 6
   
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackTime: UILabel!
    @IBOutlet weak var trackCurrentTime: UILabel!
    @IBOutlet weak var progressBar: UISlider!
    
    @IBOutlet weak var trackRate: UILabel!
    
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var allRepeatBtn: UIButton!
    @IBOutlet weak var oneRepeatBtn: UIButton!


    var notificationCenter: NotificationCenter?
    
    typealias PlayerViewControllerDependencies = (player: MP3Player, notificationCenter: NotificationCenter)

    required init?(coder aDecoder: NSCoder) {
        let audioSession = AVAudioSession.sharedInstance()
        self.player = MP3Player.sharedInstance
        self.notificationCenter = NotificationCenter.default

        super.init(coder: aDecoder)
    }
    
    deinit {
        self.notificationCenter?.removeObserver(self)
        self.timer?.invalidate()
        self.graphTimer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.notificationCenter?.removeObserver(self)
    }
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    @IBOutlet weak var mainGraphView: UIView!
    @IBOutlet weak var subGraphView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subScrollView: UIScrollView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator("graph loading...")
        
        self.notificationCenter = NotificationCenter.default
        self.configureNotifications()
        self.scrollView.delegate = self
        self.subScrollView.delegate = self
        
        setTrackName()
        setDuration()
        updateViewBackground()
        updateViewGraph()
        updateViewPlayMode()
        
        updateViews()
        updateControls()
        
        progressBar.maximumValue = (player?.getDurationFloat())!
        
        //speed label touch
        let tap = UITapGestureRecognizer(target: self, action: #selector(setRate))
        trackRate.isUserInteractionEnabled = true
        trackRate.addGestureRecognizer(tap)
        
        //메인 가로 중앙선
        drawLineFromPoint(start: CGPoint(x: 0, y: self.mainGraphView.frame.size.height/2-1), toPoint: CGPoint(x: self.mainGraphView.frame.size.width, y: self.mainGraphView.frame.size.height/2), ofColor : graphColor, lineWidth : 1, inView: self.mainGraphView)
        
        //서브 가로 중앙선
        drawLineFromPoint(start: CGPoint(x: 0, y: self.subGraphView.frame.size.height/2-1), toPoint: CGPoint(x: self.subGraphView.frame.size.width, y: self.subGraphView.frame.size.height/2), ofColor : graphColor, lineWidth : 1, inView: self.subGraphView)
        
        //메인 세로 중앙선
        drawLineFromPoint(start: CGPoint(x: self.mainGraphView.frame.size.width/2, y: 0), toPoint: CGPoint(x: self.mainGraphView.frame.size.width/2, y: self.mainGraphView.frame.size.height), ofColor : UIColor.red, lineWidth : 1, inView: self.mainGraphView)
        
        //서브 세로 중앙선
        drawLineFromPoint(start: CGPoint(x: self.subGraphView.frame.size.width/2, y: 0), toPoint: CGPoint(x: self.subGraphView.frame.size.width/2, y: self.subGraphView.frame.size.height), ofColor : UIColor.red, lineWidth : 1, inView: self.subGraphView)
        
        
        //배경색
        self.mainGraphView.backgroundColor = graphBackground
        self.subGraphView.backgroundColor = graphBackground
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.PlayerView.addGestureRecognizer(swipeDown)
        
        let gesture = UITapGestureRecognizer(target: self, action: "touchPlay:")
        
        self.scrollView.addGestureRecognizer(gesture)
        
        
    }
   
    // or for Swift 3
    func touchPlay(_ sender:UITapGestureRecognizer){
        if (player?.isPlaying)! {
            player?.pause()
        }else {
            player?.play()
        }
    }

    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    var activityIndicator = UIActivityIndicatorView()
    //로딩화면
    func activityIndicator(_ title: String) {
        
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 45, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.addSubview(activityIndicator)
        effectView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    //선그리기
    var layerArray = NSMutableArray()
    
    func drawLineFromPoint( start: CGPoint, toPoint end: CGPoint, ofColor lineColor: UIColor, lineWidth : CGFloat, inView view: UIView) {
        
        //create a path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //create a shape, and add the path to it

        let shapeLayer = CAShapeLayer()
        //        shapeLayers += shapeLayer
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        //wait till there iss data to show, so we don't get a huge spike from 0.0
        if (start != CGPoint.zero) {
            view.layer.addSublayer(shapeLayer)
        }
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    @IBAction func playSong(_ sender: AnyObject) {
        player?.play()
        
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
    
    @IBAction func playMode(_ sender: AnyObject) {
        player?.onePlayMode(state: false)
        repeatBtn.isHidden = false
        oneRepeatBtn.isHidden = true
        
        UserDefaults.standard.set(1 , forKey:"repeat")
    }
    
    @IBAction func AllPlayMode (_ sender:AnyObject){
        player?.repaetMode=true
        allRepeatBtn.isHidden = false
        repeatBtn.isHidden = true
        
        UserDefaults.standard.set(2 , forKey:"repeat")
    }
    
    @IBAction func onePlayMode(_ sender:AnyObject) {
        player?.repaetMode=false
        player?.onePlayMode(state: true)
        
        oneRepeatBtn.isHidden = false
        allRepeatBtn.isHidden = true
        
        UserDefaults.standard.set(3 , forKey:"repeat")
    }
    
    @IBAction func stopSong(_ sender: AnyObject) {
        player?.stop()
        updateViews()
    }
    
    @IBAction func pauseSong(_ sender: AnyObject) {
        player?.pause()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
//    @IBAction func playNextSong(_ sender: AnyObject) {
//        player?.nextSong(songFinishedPlaying: false)
//    }
    
    
    @IBOutlet weak var shuffle_off: UIButton!
    @IBOutlet weak var shuffle_on: UIButton!
    
    @IBAction func shufflePlay_on(_ sender: AnyObject) {
        player?.setShuffleMode(mode: true)
        shuffle_off.isHidden = false
        shuffle_on.isHidden = true
        
        UserDefaults.standard.set(true , forKey:"shuffle")
    }
    
    @IBAction func shufflePlay_off(_ sender: AnyObject) {
        player?.setShuffleMode(mode: false)
        shuffle_off.isHidden = true
        shuffle_on.isHidden = false
        
        UserDefaults.standard.set(false , forKey:"shuffle")
    }
    
    @IBAction func setVolume(_ sender: UISlider) {
        player?.setVolume(volume: sender.value)
    }
    
//    @IBAction func playPreviousSong(_ sender: AnyObject) {
//        player?.previousSong()
//    }
    
    
    func setRate(sender: UITapGestureRecognizer) {
        
            player?.setRate(rate: 1.0)
            trackRate.text = "x"+(String)(describing: Float((player?.getRate())!))
        
    }
    
    @IBAction func setUpRate(_ sender:AnyObject) {
        var tempRate = (player?.getRate())! + 0.1
        if tempRate > 2.0 {
            tempRate = 2.0
        }
        
        player?.setRate(rate: Float(tempRate))
        trackRate.text = "x"+(String)(describing: Float((player?.getRate())!))
    }
   
    @IBAction func setDownRate(_ sender:AnyObject) {

        var tempRate = round(100*((player?.getRate())! - 0.1))/100
        print(tempRate)
        if tempRate < 0.1 {
            tempRate = 0.1
            
        }
        player?.setRate(rate: Float(tempRate))
        trackRate.text = "x"+(String)(describing: Float((player?.getRate())!))
    
    }
    
    @IBAction func ChangeAudioTime(_ sender: AnyObject) {
        
        player?.changeAudioTime(sliderValue: TimeInterval(progressBar.value))
    }
    
    @IBAction func sliderTouchedDown(_ sender: UISlider) {
        print("sliderTouchedDown")
    }
    
    @IBAction func sliderTouchCanceled(_ sender: UISlider) {
        print("sliderTouchCanceled")
    }
    
    @IBAction func CurrentPlaylistOpen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CurrentPlaylistVIewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender : AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setDuration() {
        trackTime.text = player?.getDuration()
    }
    
    @IBOutlet weak var sectionRepeatBtn: UIButton!
    @IBOutlet weak var ARepeatBtn: UIButton!
    @IBOutlet weak var ABRepeatBtn: UIButton!
    
    var Asection:TimeInterval?
    var Bsection:TimeInterval?
    
    @IBAction func ASectionStart() {
        Asection = (player?.getCurrentDuration())!
        
        sectionRepeatBtn.isHidden = true
        ARepeatBtn.isHidden = false
    }
    
    @IBAction func ABRepeat() {
        Bsection = (player?.getCurrentDuration())!
        
        ARepeatBtn.isHidden = true
        ABRepeatBtn.isHidden = false
        
        player?.changeAudioTime(sliderValue: Asection!)
    }
    
    var ABRect : Draw?
    
    func DrawABSection() {
        if !ARepeatBtn.isHidden{
            ABRect?.removeFromSuperview()
            let start:CGFloat = CGFloat(Asection!*secPerPosition)
            ABRect = Draw(frame: CGRect(
                origin: CGPoint(x: start+CGFloat(self.screenSize.width * 0.5), y: 0),
                size: CGSize(width: CGFloat((player?.getCurrentDuration())!)*CGFloat(secPerPosition)-start, height: self.scrollView.frame.size.height)))
            ABRect?.alpha = 0.2
            self.scrollView.addSubview(ABRect!)
        }
    }
    
    //AB구간을 넘어간 경우
    func ABRepeatCheck() {
        if ABRepeatBtn.isHidden == false {
            if Float((player?.getCurrentDuration())!) >= Float(Bsection!) || Float((player?.getCurrentDuration())!) < Float(Asection!){
                player?.changeAudioTime(sliderValue: Asection!)
            }
        }
    }
    
    @IBAction func ABRepeatEnd() {
        ABRepeatBtn.isHidden = true
        sectionRepeatBtn.isHidden = false
        
        ABRect?.removeFromSuperview()
        ABRect=nil
        
        Asection = nil
        Bsection = nil
        
    }
    
    @IBOutlet weak var sentenceRepeatBtn_off: UIButton!
    @IBOutlet weak var sentenceRepeatBtn_on: UIButton!
    var closeTime :CGFloat = 0.0
    
    @IBAction func playPreviousSentence(_ sender: AnyObject){
        let mid = binarySearch(sentenceStartPosition: sentenceStartPosition, time: CGFloat((player?.getCurrentDuration())!*25))
        closeTime = sentenceStartPosition[mid]

        player?.setCurrentDuration(changeTime: TimeInterval(closeTime/25))
    }
    
    @IBAction func playNextSentence(_ sender: AnyObject){
        let mid = binarySearch(sentenceStartPosition: sentenceStartPosition, time: CGFloat((player?.getCurrentDuration())!*25))
        closeTime = sentenceStartPosition[mid+1]
        
        player?.setCurrentDuration(changeTime: TimeInterval(closeTime/25))
    }
    
    var mid = 0
    var RepeatRect : Draw?
    
    func DrawRepeatSection() {
        if !sentenceRepeatBtn_on.isHidden{
            RepeatRect?.removeFromSuperview()
            let start:CGFloat = CGFloat(sentenceStartPosition[mid])
            let end:CGFloat = CGFloat(sentenceEndPosition[mid])
            RepeatRect = Draw(frame: CGRect(
                origin: CGPoint(x: start+CGFloat(self.screenSize.width * 0.5), y: 0),
                size: CGSize(width:end-start, height: self.scrollView.frame.size.height)))
            RepeatRect?.alpha = 0.2
            self.scrollView.addSubview(RepeatRect!)
        }
    }
    
    @IBAction func sentenceRepeat() {
        sentenceRepeatBtn_off.isHidden = true
        sentenceRepeatBtn_on.isHidden = false
        
//        UserDefaults.standard.set(mid, forKey: "sentenceRepeat")
        
        mid = binarySearch(sentenceStartPosition: sentenceStartPosition, time: CGFloat((player?.getCurrentDuration())!*25))
        closeTime = sentenceStartPosition[mid]
        
        player?.setCurrentDuration(changeTime: TimeInterval(closeTime/25))
        
        DrawRepeatSection()
    }
    
    @IBAction func sentenceRepeatEnd() {
        sentenceRepeatBtn_off.isHidden = false
        sentenceRepeatBtn_on.isHidden = true
        
//        UserDefaults.standard.set(false, forKey: "sentenceRepeat")
        RepeatRect?.removeFromSuperview()
    }
    
    func sentenceRepeatCheck() {
        if sentenceRepeatBtn_on.isHidden == false {
            if Double((player?.getCurrentDuration())!) >= Float(sentenceEndPosition[mid])/secPerPosition || Double((player?.getCurrentDuration())!) < Float(sentenceStartPosition[mid])/secPerPosition{
                player?.changeAudioTime(sliderValue: TimeInterval(Float(sentenceStartPosition[mid])/secPerPosition))
            }
        }
    }
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector:#selector(updateViewsWithTimer), userInfo : nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func startGraphTimer() {
        graphTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector:#selector(updateViewGraphPosition), userInfo : nil, repeats: true)
        RunLoop.main.add(graphTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func updateViewGraphPosition(thisTimer: Timer ) {
        if player?.getCurrentDuration() != nil {
            let sec:TimeInterval = player!.getCurrentDuration()
            let position = sec * secPerPosition
            let subPosition = sec * subSecPerPosition
            
            //mainGraph
            self.scrollView.setContentOffset(CGPoint(x: position, y: 0), animated: false)
            //subGraph
            self.subScrollView.setContentOffset(CGPoint(x: subPosition, y: 0), animated: false)
    
        }
    }

    func updateViewsWithTimer(theTimer: Timer){
        updateViews()
    }
    
    func updateViews() {
        sentenceRepeatCheck()
        ABRepeatCheck()
        DrawABSection()
        //time
        trackCurrentTime.text = player?.getCurrentTimeAsString()
        //slider bar
        progressBar.value = Float((player?.getCurrentDuration())!)
    }
    
    func updateViewBackground() {
        if let imageSound: MPMediaItemArtwork = player?.getCurrentTrackArtwork() {
            self.backgroundImage?.image  = imageSound.image(at: CGSize(width: self.backgroundImage.frame.size.width, height: self.backgroundImage.frame.size.height))
        }else {
            self.backgroundImage?.image = UIImage(named:"basicBackground")
        }
    }
    
    func setTrackName() {
        self.titleLabel.text = player?.getCurrentTrackName()
//        self.artistLabel.text = player?.getCurrentTrackArtist()
    }
    
    func configureNotifications() {
        self.notificationCenter?.addObserver(self, selector: #selector(onTrackChanged), name: NSNotification.Name(rawValue: AudioPlayerOnTrackChangedNotification), object: nil)
        self.notificationCenter?.addObserver(self, selector: #selector(onPlaybackStateChanged), name: NSNotification.Name(rawValue: AudioPlayerOnPlaybackStateChangedNotification), object: nil)
    }
    
    func onTrackChanged() {
        if !self.isViewLoaded { return }
        
        self.scrollViewRemove()
        //mainGraph
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        //subGraph
        self.subScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        self.updateViews()
        self.setTrackName()
        self.setDuration()
        self.updateViewBackground()
      
        activityIndicator("graph loading...")
        self.updateViewGraph()
        
        progressBar.maximumValue = (player?.getDurationFloat())!
 
        self.timer?.invalidate()
        self.graphTimer?.invalidate()
        
        sectionRepeatBtn.isHidden = false
        ARepeatBtn.isHidden = true
        ABRepeatBtn.isHidden = true
        Asection = nil
        Bsection = nil
    }
    
    var audioFile:EZAudioFile!
    
    var subGraphRate :Float = 3.0 //mainGraph에 비해 몇배 작을것인가
    var graphColor:UIColor = UIColor.darkGray
    var graphBackground:UIColor = UIColor(white: 0, alpha: 0.80)
    
//    var subGraphWidth : CGFloat = 0.0
    var graphWidth : CGFloat = 0.0
    
    func updateViewGraph() {
        //audioFile
        self.player?.getUrl(completionHandler: { (url, error) in
            if let url = url {
                self.openFile(filePathURL: url)
                
                DispatchQueue.main.async {
                
                var graphCenter = self.screenSize.width * 0.5
                //maingraph draw
                   
               self.graphWidth = CGFloat(self.audioFile.totalFrames / Int64((self.player?.getSampleRate())!) * Int64(self.secPerPosition))
                    
                self.scrollView.contentSize = CGSize(width:self.graphWidth+graphCenter,height:self.scrollView.frame.size.height)
                self.scrollView.contentInset = UIEdgeInsetsMake(0.0,graphCenter,0.0,(self.screenSize.width * 0.5));
                    
                //subgraph draw
                let subGraphWidth = CGFloat(self.audioFile.totalFrames / Int64((self.player?.getSampleRate())!) * Int64(self.subSecPerPosition))
                
                self.subScrollView.contentSize = CGSize(width:subGraphWidth+graphCenter,height:self.subScrollView.frame.size.height)
                self.subScrollView.contentInset = UIEdgeInsetsMake(0.0,0.0,0.0,graphCenter);
                    
//                    let delayInSeconds = 4.0
//                    
//                    
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
//                        
//                        // here code perfomed with delay
//                        self.effectView.removeFromSuperview()
//                        
//                        self.player?.play()
//                        self.startTimer()
//                        self.startGraphTimer()
//                    }
                    
                    DispatchQueue.main.async {
                        self.effectView.removeFromSuperview()
                        
                        self.player?.play()
                        self.startTimer()
                        self.startGraphTimer()
                    }
                }
            }
        })
    }
    
    func onPlaybackStateChanged() {
        if !self.isViewLoaded { return }
        
        self.updateControls()
    }
    
    func updateControls() {
        if (self.player?.isPlaying)! {
            playButton.isHidden = true
            pauseButton.isHidden = false
        }else {
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
    
    func updateViewPlayMode() {
        if UserDefaults.standard.object(forKey:"shuffle") != nil {
            player?.shuffleMode = UserDefaults.standard.bool(forKey:"shuffle")
        }
        
        if UserDefaults.standard.object(forKey:"repeat") != nil {
            
            switch UserDefaults.standard.integer(forKey: "repeat") {
            case 1:
                player?.repaetMode = false
                player?.oneRepeatMode = false
                break
            case 2:
                player?.repaetMode = true
                player?.oneRepeatMode = false
                break
            case 3:
                player?.repaetMode = false
                player?.oneRepeatMode = true
                break
            default: break
            }
        }
        
//        if UserDefaults.standard.object(forKey: "sentenceRepeat") != nil {
//            if UserDefaults.standard.integer(forKey:"sentenceRepeat") != nil{
//                sentenceRepeatBtn_on.isHidden = false
//                sentenceRepeatBtn_off.isHidden = true
//            }else {
//                sentenceRepeatBtn_on.isHidden = true
//                sentenceRepeatBtn_off.isHidden = false
//            }
//        }

        if (player?.shuffleMode)! {
            shuffle_off.isHidden = false
            shuffle_on.isHidden = true
        }else {
            shuffle_off.isHidden = true
            shuffle_on.isHidden = false
        }
        

        if (player?.repaetMode)! {
            allRepeatBtn.isHidden = false
            repeatBtn.isHidden = true
        }else {
            if (player?.oneRepeatMode)! {
                oneRepeatBtn.isHidden = false
                allRepeatBtn.isHidden = true
                repeatBtn.isHidden = true
            }else{
                allRepeatBtn.isHidden = true
                repeatBtn.isHidden = false
                oneRepeatBtn.isHidden = true
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CurrentPlaylistTableViewController {
            controller.delegate = self

            if segue.identifier == "playlistSegue" {
                slideInTransitioningDelegate.direction = .right
                controller.transitioningDelegate = slideInTransitioningDelegate
                controller.modalPresentationStyle = .custom
            
                controller.albums = self.albums
            }
        }
    }
    
    func CurrentPlayListDelegate(currentTrackIndex: Int) {
        player?.stop()
        player?.setCurrentTrackIndex(currentTrackIndex: currentTrackIndex)
        player?.queueTrack()
        player?.play()

        onTrackChanged()
    }

    var sentenceStartPosition : [CGFloat] = [0]
    var sentenceEndPosition : [CGFloat] = [0]
    
    func openFile(filePathURL:URL) {
        self.audioFile = EZAudioFile(url: filePathURL)
        self.audioFile.delegate = self
        
        let totalPoint = secPerPosition * Int(self.audioFile.totalFrames) / Int((player?.getSampleRate())!)
        self.audioFile.getWaveformData(withNumberOfPoints: UInt32(totalPoint), completion: {
            (buffers:UnsafeMutablePointer<UnsafeMutablePointer<Float>?>?, bufferSize:Int32) -> Void in

            var blankStart :Int = -1
            
            for i in 0...Int(bufferSize) {
                let scrollViewHeight = self.scrollView.frame.size.height
                let yStartPoint = (scrollViewHeight - (CGFloat((buffers?[0]?[i])!)*250*2))/2
                let yEndPoint = yStartPoint+(CGFloat((buffers?[0]?[i])!)*250*2)
                
                let xPoint = CGFloat(i)

                //그래프
                self.drawLineFromPoint(start: CGPoint(x: xPoint + self.screenSize.width * 0.5, y: yStartPoint), toPoint: CGPoint(x: xPoint + self.screenSize.width * 0.5, y: yEndPoint), ofColor : UIColor.white, lineWidth : 0.5, inView: self.scrollView)

                //////////////////////////
//                var number: Int = Int(4410.0/(self.player?.getDurationFloat())!/2.0)
                let number : Int = 2
                
                //데시벨 0
                if ((buffers?[0]?[i])! <= Float(0.01)) {
                    if blankStart == -1 {
                        blankStart = i
                    }
                    //데시벨 0, 5초 유지
                    if blankStart != -1 && i-blankStart >= number {
                        if self.sentenceEndPosition[self.sentenceEndPosition.count-1] != CGFloat(blankStart) {
                            self.sentenceEndPosition.append(CGFloat(blankStart))
                        }
                        let bar : CGFloat = 15
                        
                        self.drawLineFromPoint(start: CGPoint(x: CGFloat(blankStart) + self.screenSize.width * 0.5, y: self.scrollView.frame.size.height/2-bar), toPoint: CGPoint(x: CGFloat(blankStart) + self.screenSize.width * 0.5, y: self.scrollView.frame.size.height/2+bar), ofColor : UIColor.yellow, lineWidth : 1, inView: self.scrollView)
                        
                        if (buffers?[0]?[i+1])! > Float(0.01) {
                            self.sentenceStartPosition.append(xPoint)
                            self.drawLineFromPoint(start: CGPoint(x: xPoint + self.screenSize.width * 0.5, y: self.scrollView.frame.size.height/2-bar), toPoint: CGPoint(x: xPoint + self.screenSize.width * 0.5, y: self.scrollView.frame.size.height/2+bar), ofColor : UIColor.green, lineWidth : 1, inView: self.scrollView)
                        }
                    }
                    
                }else {
                    blankStart = -1
                }
                
                //눈금
                if 10.truncatingRemainder(dividingBy: Double(xPoint)) == 0 {

                    self.drawLineFromPoint(start: CGPoint(x: xPoint+self.screenSize.width * 0.5, y: self.scrollView.frame.size.height-20), toPoint: CGPoint(x: xPoint+self.screenSize.width * 0.5, y: self.scrollView.frame.size.height), ofColor : UIColor.red, lineWidth : 0.07, inView: self.scrollView)
                }else if 5.truncatingRemainder(dividingBy: Double(xPoint)) == 0{

                    self.drawLineFromPoint(start: CGPoint(x: xPoint+self.screenSize.width * 0.5, y: self.scrollView.frame.size.height-10), toPoint: CGPoint(x: xPoint+self.screenSize.width * 0.5, y: self.scrollView.frame.size.height), ofColor : UIColor.red, lineWidth : 0.07, inView: self.scrollView)
                }
            }
            
        })
        print(sentenceEndPosition)
        
        
        let totalPoint2 = subSecPerPosition * Int(self.audioFile.totalFrames) / Int((player?.getSampleRate())!)
        self.audioFile.getWaveformData(withNumberOfPoints: UInt32(totalPoint2), completion: {
            (buffers:UnsafeMutablePointer<UnsafeMutablePointer<Float>?>?, bufferSize:Int32) -> Void in
            
            let blankStart :Int = -1
            
            for i in 0...Int(bufferSize) {
                
                let subScrollViewHeight = self.subScrollView.frame.size.height
                let subGraphYStartPoint = (subScrollViewHeight - (CGFloat((buffers?[0]?[i])!)*50*2))/2
                let subGraphYEndPoint = subGraphYStartPoint+(CGFloat((buffers?[0]?[i])!)*50*2)
                
                let xPoint = CGFloat(i)
                
                //서브그래프
                self.drawLineFromPoint(start: CGPoint(x: xPoint + self.screenSize.width * 0.5, y: subGraphYStartPoint), toPoint: CGPoint(x: xPoint + self.screenSize.width * 0.5, y: subGraphYEndPoint), ofColor : UIColor.white, lineWidth : 0.5, inView: self.subScrollView)
            }
        })
        
        
    }

    func binarySearch(sentenceStartPosition : [CGFloat], time : CGFloat) -> Int{
        print("sentenceStartPosition")
        for sen in sentenceStartPosition {
            print(sen)
        }
        
        print("sentenceEndPosition")
        for sen in sentenceEndPosition {
            print(sen)
        }
        
        var left = 0
        var right = sentenceStartPosition.count-1
        var mid : Int = 0

        while (left <= right) {
            mid = ( left + right ) / 2
            if sentenceStartPosition[mid] > time {
                right = mid - 1
            } else if sentenceStartPosition[mid] < time {
                left = mid + 1
            }else {
                
            }
        }
        
        if time > sentenceStartPosition[mid] {
            
        }else if time < sentenceStartPosition[mid] {
            mid = mid - 1
        }
        
        return mid
    }
    
    func scrollViewRemove() {
        
        let subViews = self.scrollView.subviews
        let subSubViews = self.subScrollView.subviews
        
//        subViews =  nil
//        for layer in self.scrollView.layer.sublayers! {
//            layer.removeFromSuperlayer()
//        }
        for subview in subViews{
            subview.removeFromSuperview()
            subview.layer.removeFromSuperlayer()
//            subview.removeFromSuperlayer()
//            subview.layer.sublayers = nil
            
//            subview.layer.zPosition = -1
        }
//
        for subview in subSubViews {
            subview.removeFromSuperview()
            subview.layer.sublayers = nil
            subview.layer.removeFromSuperlayer()
//            subview.layer.zPosition = -1
        }
        
    }
    
    var scrollStart : CGPoint = CGPoint(x:0, y:0)
    var scrollEnd : CGPoint = CGPoint(x:0, y:0)
    var isTouchingScrollView : Bool = false
    
    //스크롤 시작 지점
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
//        player?.stop()
        scrollStart = scrollView.contentOffset
        isTouchingScrollView = true
        print("scrollViewWillBeginDragging")
        
    }
    
    //사용자가 콘텐츠 스크롤을 마쳤을 때
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>){
 
        print("scrollViewWillEndDragging")

        let contentSize = scrollView.contentSize.width
        
        if touchedViewKind(scrollViewWidth: contentSize) == "main" {
            //TODO
            player?.changeAudioTime(sliderValue: TimeInterval(scrollEnd.x / CGFloat(self.secPerPosition)))
        } else if touchedViewKind(scrollViewWidth: contentSize) == "sub"{
            //TODO
            player?.changeAudioTime(sliderValue: TimeInterval(scrollEnd.x / CGFloat(self.subSecPerPosition)))
        }

        isTouchingScrollView = false
    }
    
    //스크롤 하는 중
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        scrollEnd = scrollView.contentOffset
        let contentSize = scrollView.contentSize.width

        if isTouchingScrollView {
            if touchedViewKind(scrollViewWidth: contentSize) == "main" {
                //TODO
                player?.changeAudioTime(sliderValue: TimeInterval(scrollEnd.x / CGFloat(self.secPerPosition)))

            } else if touchedViewKind(scrollViewWidth: contentSize) == "sub"{
                //TODO
                player?.changeAudioTime(sliderValue: TimeInterval(scrollEnd.x / CGFloat(self.subSecPerPosition) ))
            }
        }
    }
    //감속하는 중 
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){

        isTouchingScrollView = true
    }
    
    //날리기 끝
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        print("scrollViewDidEndDeceleration")
        let contentSize = scrollView.contentSize.width
        
        if touchedViewKind(scrollViewWidth: contentSize) == "main" {
            //TODO
            player?.changeAudioTime(sliderValue: TimeInterval(scrollEnd.x / CGFloat(self.secPerPosition)))
        } else if touchedViewKind(scrollViewWidth: contentSize) == "sub"{
            //TODO
            player?.changeAudioTime(sliderValue: TimeInterval(scrollEnd.x / CGFloat(self.subSecPerPosition) ))
        }
        
        isTouchingScrollView = false
    }

    func touchedViewKind(scrollViewWidth : CGFloat) ->String {
    
        if (graphWidth+(self.screenSize.width * 0.5)) == scrollViewWidth {
            
            return "main"
        }else {
            return "sub"
        }
    }

}


class Draw: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let h = rect.height
        let w = rect.width
        var color:UIColor = UIColor.white
        
        var drect = CGRect(x: 0,y: 0,width: w,height: h)
        var bpath:UIBezierPath = UIBezierPath(rect: drect)

        color.set()
        bpath.fill()
//        bpath.stroke()
        
    }
    
}
