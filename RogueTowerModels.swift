// RogueTowerModels.swift

import Foundation

struct RogueTower {
    var id: Int
    var name: String
    var location: String
    var health: Int
}

struct RogueTowerList {
    var towers: [RogueTower]
    
    func towerNames() -> [String] {
        return towers.map { $0.name }
    }
}
