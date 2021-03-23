//
//  ContentView.swift
//  NLUTimer
//
//  Created by Chia-Hung Wan on 2021/3/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var time = ""
    
    var body: some View {
        TextField("1h3m, @5pm", text: $time)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue, lineWidth: 1))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
