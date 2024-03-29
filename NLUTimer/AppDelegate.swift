//
//  AppDelegate.swift
//  NLUTimer
//
//  Created by Chia-Hung Wan on 2021/3/23.
//

import Cocoa
import SwiftUI
import AVFoundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    // Set global shortcut to Command+Option+k
    static let togglePopover = Self("togglePopover", default: .init(.k, modifiers: [.option, .command]))
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static var popoverWidth = 280
    static var popoverHeight = 130
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var contentView: ContentView!
    var nlutimer = NLUTimer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.nlutimer = NLUTimer()

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(nlutimer: self.nlutimer)
        self.contentView = contentView
        
        let viewController = NSHostingController(rootView: contentView)

        // Create popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: AppDelegate.popoverWidth, height: AppDelegate.popoverHeight)
        popover.behavior = .transient
        popover.contentViewController = viewController
        popover.animates = false
        self.popover = popover

        // Create status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.action = #selector(togglePopover(_:))
        }
        
        // Set shortcut action
        KeyboardShortcuts.onKeyUp(for: .togglePopover) { [self] in
            self.togglePopover(self)
        }
        
        // Pass object to let nlutimer take control
        self.nlutimer.setStatusBarItem(statusBarItem: self.statusBarItem)
        self.nlutimer.setPopover(popover: self.popover)
        
        // Show popover at start
        self.togglePopover(nil)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
                NSApplication.shared.hide(sender)
                self.nlutimer.timeTextTimer?.invalidate()
            } else {
                NSApplication.shared.activate(ignoringOtherApps: true)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
                self.nlutimer.audioPlayer.stop()
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
                self.nlutimer.updateTimeText()
                self.nlutimer.timeTextTimer?.invalidate()
                self.nlutimer.timeTextTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
                    self.nlutimer.updateTimeText()
                })
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

class NLUTimer: NSObject, NSUserNotificationCenterDelegate, ObservableObject {
    var time = 0
    var userInputTime = 0
    var timerRunning = false
    var timerLoop = false
    var soundIndex = 3
    var soundPath = ["mixkit - Cool guitar riff", "mixkit - Happy guitar chords", "mixkit - Musical alert notification", "mixkit - Flute mobile phone notification alert", "mixkit - Video game win"]
    var soundType = "wav"
    var audioPlayDefaultCount = [5, 5, 5, 3, 3] // Will play music 6 times if number is set to 5
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    var timer: Timer?
    var audioPlayer = AVAudioPlayer()
    var timeTextTimer: Timer?
    @Published var timeText: String = ""
    
    override init() {
        super.init()
        self.setAudioPlayer(index: self.soundIndex)
    }
    
    func setAudioPlayer(index: Int) {
        let bundle = Bundle.main
        guard let sound = bundle.path(forResource: self.soundPath[index], ofType: self.soundType) else { return }
        do {
            print("Found sound file")
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
        } catch {
            print("Sound file not found")
        }
        self.soundIndex = index
    }
    
    func onCommit(text: String) {
        // Handle user input while enter is pressed in textfield
        print("User input: " + text)
        self.time = self.convert_time_string_to_seconds(time: text)
        self.userInputTime = self.time
        
        // Not sure why calling setTimeToStatusBar() here causes onCommit() to be triggered twice
        // Use another timer to update time as a workaround
        // self.setTimeToStatusBar()
        self.updateStatusBarOnCommit()
        
        self.invalidateTimer()
        self.togglePopover()
        if self.time != 0 {
            self.createTimer()
        }
    }
    
    func updateStatusBarOnCommit() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { timer in
            self.setTimeToStatusBar()
        })
    }
    
    func createTimer() {
        self.invalidateTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.update()
        })
        self.timerRunning = true
    }
    
    func invalidateTimer() {
        self.timer?.invalidate()
        self.timerRunning = false
    }
    
    func convert_time_string_to_seconds(time: String) -> Int {
        let time = String(time.filter { !" \n\t\r".contains($0) })
        let hours = self.splitTimeByKeyword(time: time, keyword: "h")
        let minutes = self.splitTimeByKeyword(time: time, keyword: "m")
        let seconds = self.splitTimeByKeyword(time: time, keyword: "s")
        print("Hours = " + String(hours))
        print("Minutes = " + String(minutes))
        print("Seconds = " + String(seconds))
        return hours*3600 + minutes*60 + seconds
    }
    
    func splitTimeByKeyword(time: String, keyword: String) -> Int {
        let pattern = "[0-9]*" + keyword
        let regex = try! NSRegularExpression(pattern: pattern)
        let results = regex.matches(in: time, range: NSRange(time.startIndex..., in: time))
        let retrieved = results.map {String(time[Range($0.range, in: time)!])}
        if retrieved.count != 0 {
            return Int(retrieved[0].dropLast()) ?? 0
        }
        return 0
    }
    
    func convert_seconds_to_string() -> String {
        let seconds = self.time % 60
        let minutes = (self.time-seconds) / 60 % 60
        let hours = (self.time-seconds-60*minutes) / 3600
        if hours != 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func update() {
        self.time -= 1
        print("Remaining time = " + String(self.time) + " s")
        self.setTimeToStatusBar()
        if self.time == 0 {
            print("Time's up !!!!!")
            self.invalidateTimer()
            self.showNotification()
            self.playMusic()
            if self.timerLoop {
                self.time = self.userInputTime
                self.setTimeToStatusBar()
                self.createTimer()
            }
        }
    }
    
    func playMusic() {
        self.audioPlayer.numberOfLoops = self.audioPlayDefaultCount[self.soundIndex]
        self.audioPlayer.currentTime = 0
        self.audioPlayer.play()
    }
    
    func showNotification() {
        let notification = NSUserNotification()
        notification.title = "Time's Up !!!"
        notification.informativeText = "Click notification to dismiss"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        print("Click notification")
        self.audioPlayer.stop()
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    }
    
    func setTimeToStatusBar(){
        if self.time == 0 {
            if let button = self.statusBarItem.button {
                button.image = NSImage(named: "Icon")
                button.title = ""
            }
        }
        else {
            if let button = self.statusBarItem.button {
                button.image = NSImage()
                button.title = self.convert_seconds_to_string()
            }
        }
        self.updateTimeText()
    }
    
    func toggleTimer() -> Bool {
        if self.timerRunning {
            print("Pause")
            self.invalidateTimer()
        }
        else {
            print("Continue")
            if self.time != 0 {
                self.createTimer()
            }
        }
        return self.timerRunning
    }
    
    func stopTimer() {
        print("Stop")
        self.invalidateTimer()
        self.time = 0
        self.setTimeToStatusBar()
    }
    
    func toggleLoop() -> Bool {
        print("Toggle Loop")
        self.timerLoop.toggle()
        print("Loop =", self.timerLoop)
        return self.timerLoop
    }
    
    func setStatusBarItem(statusBarItem: NSStatusItem){
        self.statusBarItem = statusBarItem
    }
    
    func setPopover(popover: NSPopover){
        self.popover = popover
    }
    
    func simulateToggleShortcut() {
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let commandDown = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
        let commandUp = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
        let optionDown = CGEvent(keyboardEventSource: src, virtualKey: 0x3A, keyDown: true)
        let optionUp = CGEvent(keyboardEventSource: src, virtualKey: 0x3A, keyDown: false)
        let kDown = CGEvent(keyboardEventSource: src, virtualKey: 0x28, keyDown: true)
        let kUp = CGEvent(keyboardEventSource: src, virtualKey: 0x28, keyDown: false)

        commandDown?.flags = CGEventFlags.maskCommand;
        optionDown?.flags = CGEventFlags.maskCommand;

        let loc = CGEventTapLocation.cghidEventTap

        commandDown?.post(tap: loc)
        optionDown?.post(tap: loc)
        kDown?.post(tap: loc)
        kUp?.post(tap: loc)
        optionUp?.post(tap: loc)
        commandUp?.post(tap: loc)
        print("Simulate command+option+k")
    }
    
    func togglePopover() {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(self.statusBarItem)
                NSApplication.shared.hide(nil)
                self.timeTextTimer?.invalidate()
            } else {
                NSApplication.shared.activate(ignoringOtherApps: true)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
                self.audioPlayer.stop()
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
                self.updateTimeText()
                self.timeTextTimer?.invalidate()
                self.timeTextTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                    self.updateTimeText()
                })
            }
        }
    }
    
    func getCurrentTime() -> String{
        let today = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: today)
        let minute = calendar.component(.minute, from: today)
        let second = calendar.component(.second, from: today)
        return String(format: "%02d", hour) + ":" + String(format: "%02d", minute) + ":" + String(format: "%02d", second)
    }
    
    func updateTimeText() {
        self.timeText = "🕒" + self.getCurrentTime() + "  ⏰" + self.convert_seconds_to_string()
    }
}
