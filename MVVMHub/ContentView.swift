//
//  ContentView.swift
//  MVVMHub
//
//  Created by Yusuke Ohashi on 2022/05/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var repoListVM = RepoListViewModel()
    @State private var userName: String = ""
    @State private var isAlertPresented: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            List(repoListVM.repos, id:\.id) {
                repo in
                Text(repo.name)
            }.listStyle(.plain)
                .searchable(text: $userName)
                .onSubmit(of: .search, {
                    Task {
                        if !userName.isEmpty {
                            do {
                                try await repoListVM.search(username: userName)
                            } catch {
                                repoListVM.repos.removeAll()
                                switch error {
                                case GithubError.basicError(let error):
                                    errorMessage = error.message ?? ""
                                    isAlertPresented = true
                                case GithubError.overRateLimit(_, let resetDate):
                                    let dateFormatter = DateFormatter()
                                    let resetDateString = dateFormatter.string(from: resetDate)
                                    errorMessage = "You reached rate limit. It is reset at \(resetDateString)."
                                    isAlertPresented = true
                                default:
                                    break
                                }
                            }
                        } else {
                            repoListVM.repos.removeAll()
                        }
                    }
                })
                .navigationTitle("Github Repos")
        }
        .alert("Error", isPresented: $isAlertPresented,
               actions: {
            Button("OK", action: {})
        }, message: {
            Text(errorMessage)
        })
        
    }
    
    var searchResult: [Repo] {
        return [
            Repo(id: 12345, name: "test repo")
        ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
