//
//  ViewModel.swift
//  MVVMHub
//
//  Created by Yusuke Ohashi on 2022/05/24.
//

import Foundation

@MainActor
class RepoListViewModel: ObservableObject {
    
    @Published var repos: [RepoViewModel] = []
    
    func search(username: String) async throws {
        let repos = try await API().getRepos(for: username)
        self.repos = repos.map(RepoViewModel.init)
    }
}

struct RepoViewModel {
    let repo: Repo
    
    var id: Int {
        return repo.id
    }
    
    var name: String {
        return repo.name
    }
}
