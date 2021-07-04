//
//  ContentView.swift
//  NLUTimer
//
//  Created by Chia-Hung Wan on 2021/3/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var time = ""
    @State private var typing = false
    @State private var playButtonWidth = CGFloat(100.0)
    @State private var buttonWidth = CGFloat(50.0)
    @State private var buttonHeight = CGFloat(50.0)
    @State private var timerRunning = false
    @State private var timerLoop = false
    var nlutimer: NLUTimer!
    
    var body: some View {
        TextField("1h3m, 300s [Press Enter]", text: $time, onEditingChanged: {
            self.typing = $0
        }, onCommit: {
            self.nlutimer.onCommit(text: self.time)
        })
            .font(Font.custom("Arial", size: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
        HStack{
            // Pause / Recume button
            // Due to multiple logics may occur, rollback to Pause/Resume
//            if timerRunning || self.nlutimer.time == 0 {
//                Button(action: {
//                    timerRunning = self.nlutimer.toggleTimer()
//                }) {
//                    Text("Pause")
//                }
//                .frame(maxWidth: playButtonWidth, maxHeight: buttonHeight, alignment: .bottomLeading)
//            } else {
//                Button(action: {
//                    timerRunning = self.nlutimer.toggleTimer()
//                }) {
//                    Text("Resume")
//                }
//                .frame(maxWidth: playButtonWidth, maxHeight: buttonHeight, alignment: .bottomLeading)
//                .colorInvert()
//            }
            Button(action: {
                timerRunning = self.nlutimer.toggleTimer()
            }) {
                Text("Pause/Resume")
            }
            .frame(maxWidth: playButtonWidth, maxHeight: buttonHeight, alignment: .bottomLeading)
            
            // Stop button
            Button(action: {
                self.nlutimer.stopTimer()
            }) {
                Text("Stop")
            }
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottom)
            
            // Loop button
            if timerLoop {
                Button(action: {
                    timerLoop = self.nlutimer.toggleLoop()
                }) {
                    Text("Loop")
                }
                .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottom)
                .colorInvert()
            } else {
                Button(action: {
                    timerLoop = self.nlutimer.toggleLoop()
                }) {
                    Text("Loop")
                }
                .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottom)
            }
            
            // Quit button
            Button(action: {
                quitProgram()
            }) {
                Text("Quit")
                    .foregroundColor(.black)
            }
            .background(Color.blue)
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottomTrailing)
        }
        if #available(OSX 11.0, *) {
            Menu("Choose music...") {
                ForEach(0..<self.nlutimer.soundPath.count) { index in
                    Button(action: {
                        print("Select music ", index)
                        self.nlutimer.setAudioPlayer(index: index)
                    }) {
                        Text(self.nlutimer.soundPath[index])
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    init(nlutimer: NLUTimer){
        self.nlutimer = nlutimer
    }
     
    func quitProgram() {
        print("Quit program QQ")
        NSApplication.shared.terminate(self)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
