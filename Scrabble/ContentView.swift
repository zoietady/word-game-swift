//
//  ContentView.swift
//  Scrabble
//
//  Created by Zoie Tad-y on 6/30/20.
//  Copyright © 2020 Zoie Tad-y. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView{
            ZStack {
                 LinearGradient(gradient: Gradient(colors:[Color(red: 105 / 255, green: 207 / 255, blue: 231 / 255), Color(red: 32 / 255, green: 142 / 255, blue: 171 / 255)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                
                VStack{
                        TextField("Enter your word", text: $newWord, onCommit: addWord)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .padding()
                            .opacity(0.7)
                        
                        List(usedWords, id:\.self){
                            Image(systemName: "\($0.count).circle")
                            Text($0)
                        }
                        .cornerRadius(8)
                        .padding()
                        .padding(.top,-23)
                        .opacity(0.5)
                        .onAppear{UITableView.appearance().separatorStyle = .none}
                    }
                    .navigationBarItems(
                        leading:
                        HStack {
                            Text(rootWord)
                                .fontWeight(.bold)
                        }
                        .font(.title)
                        .padding(.top, 40),
                        trailing:
                        HStack{
                            Text("score")
                            .fontWeight(.bold)
                            Image(systemName: "\(score).circle")
                        }
                        .font(.title)
                        .padding(.top, 40))
                    .onAppear(perform: startGame)
                    .alert(isPresented: $showingError) {
                        Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                .padding(.top,-30)
            }
        }
    }
    
    func addWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else{
            return
        }
        
        guard isOrginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not recognized", message: "That didn't even come from the word given")
            return
        }
        
        guard isReal(word: answer) else{
            wordError(title: "Not even a word", message: "Okay that's too original")
            return
        }
        
        usedWords.insert(newWord, at: 0)
        score += newWord.count
        newWord = ""
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "potato"
                return
            }
        }
        
        fatalError("Could not load")
    }
    
    func isOrginal (word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible (word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal (word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
