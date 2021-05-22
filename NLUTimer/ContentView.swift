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
    @State private var buttonWidth = CGFloat(50.0)
    @State private var buttonHeight = CGFloat(50.0)
    var nlutimer: NLUTimer!
    
    var body: some View {
        TextField("1h3m, 300s", text: $time, onEditingChanged: {
            self.typing = $0
        }, onCommit: {
            self.nlutimer.onCommit(text: self.time)
        })
            .font(Font.custom("Arial", size: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
        HStack{
            Button(action: {
                self.nlutimer.toggleTimer()
            }) {
                Image("Play")
                    .renderingMode(.template)
            }
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottomLeading)
        
            Button(action: {
                self.nlutimer.stopTimer()
            }) {
                Image("Stop")
                    .renderingMode(.template)
            }
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottom)
        
            Button(action: {
                quitProgram()
            }) {
                Image("Quit")
                    .renderingMode(.template)
            }
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottomTrailing)
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
