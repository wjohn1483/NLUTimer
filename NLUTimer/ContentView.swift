//
//  ContentView.swift
//  NLUTimer
//
//  Created by Chia-Hung Wan on 2021/3/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var time = ""
    @State private var buttonWidth = CGFloat(50.0)
    @State private var buttonHeight = CGFloat(50.0)
    
    var body: some View {
        TextField("1h3m, @5pm", text: $time)
            .font(Font.custom("Arial", size: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
        HStack{
            Button(action: {
                toggleTimer()
            }) {
                Image("Play")
                    .renderingMode(.template)
            }
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight, alignment: .bottomLeading)
        
            Button(action: {
                stopTimer()
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
    
    func toggleTimer() {
        print("Toggle timer...")
    }
    
    func stopTimer() {
        print("Stop timer!")
    }
    
    func quitProgram() {
        print("Quit program QQ")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
