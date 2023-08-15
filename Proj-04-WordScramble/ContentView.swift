//
//  ContentView.swift
//  Proj-04-WordScramble
//
//  Created by Андрей Бородкин on 15.08.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingMessage = false
    
    var playerScore: Int {
        return usedWords.count
    }
    
    @State private var anotherPlayerScore = 0
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .onSubmit(addNewWord)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                } header: {
                    Text("Your score is \(anotherPlayerScore)")
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingMessage) {
                Button("OK", role: .cancel) {}
            }message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("New word") {startGame()}
        }
       
        }
        
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
       
        guard runChecks(with: answer) else {return}
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        anotherPlayerScore += answer.count
        newWord = ""
    }
    
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                anotherPlayerScore = 0
                newWord = ""
                usedWords = []
                return
            }
            fatalError("Could not load start.txt from bundle")
        }
    }
    
    func runChecks(with answer: String) -> Bool {
        guard answer.count > 0 else {return false}
        
        // Extra validations
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more creative")
            return false
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell this word from \(rootWord)")
            return false
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up, you know")
            return false
        }
        
        guard isLong(word: answer) else {
            wordError(title: "Word is too short", message: "Your word shouldn't be less than 3 characters long")
            return false
        }
        
        guard isNotDuplicate(word: answer) else {
            wordError(title: "Word is duplicate", message: "You can't use same word as the given one")
            return false
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLong(word: String) -> Bool {
        word.count < 3 ? false : true
    }
    
    func isNotDuplicate(word: String) -> Bool {
        word == rootWord ? false : true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingMessage = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
