// InvasionThreat.swift
// Threat model representing a detected invasion threat with identity and status fields

import Foundation

struct InvasionThreat {
    var id: Int
    var name: String
    var location: String
    var health: Int
}

struct InvasionThreatList {
    var threats: [InvasionThreat]

    func threatNames() -> [String] {
        return threats.map { $0.name }
    }
}
