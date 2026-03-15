import Foundation
import CoreLocation

// MARK: - User Profile
struct UserProfile: Codable {
    var id: UUID = UUID()
    var name: String
    var age: Int
    var level: SkaterLevel
    var unlockedTricks: [String]
    var xp: Int = 0
    var totalSessions: Int = 0
    var totalDistanceKm: Double = 0
    var totalCalories: Double = 0
    
    var levelProgress: Double {
        let xpForNextLevel = 1000
        return Double(xp % xpForNextLevel) / Double(xpForNextLevel)
    }
}

enum SkaterLevel: String, Codable, CaseIterable {
    case amateur = "Amateur"
    case intermediate = "Intermediate"
    case professional = "Professional"
    
    var description: String {
        switch self {
        case .amateur: return "Just starting out, learning the basics"
        case .intermediate: return "Comfortable with fundamentals, expanding tricks"
        case .professional: return "Advanced skater, mastering complex maneuvers"
        }
    }
    
    var icon: String {
        switch self {
        case .amateur: return "figure.walk"
        case .intermediate: return "figure.run"
        case .professional: return "star.fill"
        }
    }
    
    var xpMultiplier: Double {
        switch self {
        case .amateur: return 1.0
        case .intermediate: return 1.5
        case .professional: return 2.0
        }
    }
}

// MARK: - Tricks
struct SkateTrick: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var difficulty: TrickDifficulty
    var category: TrickCategory
    var xpReward: Int
    var description: String
    
    init(id: UUID = UUID(), name: String, difficulty: TrickDifficulty, category: TrickCategory, xpReward: Int, description: String) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.category = category
        self.xpReward = xpReward
        self.description = description
    }
}

enum TrickDifficulty: String, Codable, CaseIterable {
    case beginner, intermediate, advanced, expert
    
    var color: String {
        switch self {
        case .beginner: return "#4CAF50"
        case .intermediate: return "#2196F3"
        case .advanced: return "#FF9800"
        case .expert: return "#F44336"
        }
    }
}

enum TrickCategory: String, Codable, CaseIterable {
    case flatground = "Flat Ground"
    case grinds = "Grinds"
    case flips = "Flips"
    case airs = "Airs"
    case manuals = "Manuals"
}

// MARK: - Spots
struct SkateSpot: Identifiable {
    let id: UUID = UUID()
    var name: String
    var type: SpotType
    var coordinate: CLLocationCoordinate2D
    var distanceMeters: Double
    var rating: Double
    var imageName: String
    
    var distanceText: String {
        if distanceMeters < 1000 {
            return "\(Int(distanceMeters))m"
        } else {
            return String(format: "%.1fkm", distanceMeters / 1000)
        }
    }
}

enum SpotType: String {
    case plaza = "Plaza"
    case park = "Skate Park"
    case street = "Street"
    case bowl = "Bowl"
    case diy = "DIY"
    
    var icon: String {
        switch self {
        case .plaza: return "building.2"
        case .park: return "figure.skating"
        case .street: return "road.lanes"
        case .bowl: return "circle.dashed"
        case .diy: return "hammer"
        }
    }
}

// MARK: - Training Session
struct TrainingSession: Identifiable, Codable {
    let id: UUID
    var date: Date
    var duration: TimeInterval
    var distanceKm: Double
    var calories: Double
    var pushCount: Int
    var tricksAttempted: [String]
    var routePoints: [RoutePoint]
    
    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval = 0, distanceKm: Double = 0, calories: Double = 0, pushCount: Int = 0, tricksAttempted: [String] = [], routePoints: [RoutePoint] = []) {
        self.id = id
        self.date = date
        self.duration = duration
        self.distanceKm = distanceKm
        self.calories = calories
        self.pushCount = pushCount
        self.tricksAttempted = tricksAttempted
        self.routePoints = routePoints
    }
}

struct RoutePoint: Codable {
    var latitude: Double
    var longitude: Double
    var timestamp: Date
}

// MARK: - All Tricks Data
extension SkateTrick {
    static let allTricks: [SkateTrick] = [
        // Flat Ground
        SkateTrick(name: "Ollie", difficulty: .beginner, category: .flatground, xpReward: 50, description: "The fundamental jump"),
        SkateTrick(name: "Nollie", difficulty: .intermediate, category: .flatground, xpReward: 100, description: "Nose ollie"),
        SkateTrick(name: "Fakie Ollie", difficulty: .beginner, category: .flatground, xpReward: 60, description: "Ollie going fakie"),
        SkateTrick(name: "Manual", difficulty: .beginner, category: .manuals, xpReward: 40, description: "Balance on back wheels"),
        SkateTrick(name: "Nose Manual", difficulty: .intermediate, category: .manuals, xpReward: 80, description: "Balance on front wheels"),
        // Flips
        SkateTrick(name: "Kickflip", difficulty: .intermediate, category: .flips, xpReward: 150, description: "Board flips along long axis"),
        SkateTrick(name: "Heelflip", difficulty: .intermediate, category: .flips, xpReward: 150, description: "Board flips with heel"),
        SkateTrick(name: "Pop Shuvit", difficulty: .beginner, category: .flips, xpReward: 80, description: "Board rotates 180° horizontally"),
        SkateTrick(name: "Varial Kickflip", difficulty: .advanced, category: .flips, xpReward: 200, description: "Kickflip with shuvit"),
        SkateTrick(name: "Hardflip", difficulty: .advanced, category: .flips, xpReward: 250, description: "Kickflip with frontside pop shuvit"),
        SkateTrick(name: "Inward Heel", difficulty: .advanced, category: .flips, xpReward: 250, description: "Heelflip with backside shuvit"),
        SkateTrick(name: "360 Flip", difficulty: .advanced, category: .flips, xpReward: 300, description: "Kickflip with 360 shuvit"),
        SkateTrick(name: "Double Kickflip", difficulty: .expert, category: .flips, xpReward: 400, description: "Two kickflips"),
        // Grinds
        SkateTrick(name: "50-50 Grind", difficulty: .beginner, category: .grinds, xpReward: 100, description: "Both trucks on obstacle"),
        SkateTrick(name: "5-0 Grind", difficulty: .intermediate, category: .grinds, xpReward: 130, description: "Back truck only grind"),
        SkateTrick(name: "Boardslide", difficulty: .beginner, category: .grinds, xpReward: 90, description: "Board perpendicular on obstacle"),
        SkateTrick(name: "Noseslide", difficulty: .intermediate, category: .grinds, xpReward: 120, description: "Nose on obstacle"),
        SkateTrick(name: "Tailslide", difficulty: .intermediate, category: .grinds, xpReward: 120, description: "Tail on obstacle"),
        SkateTrick(name: "Crooked Grind", difficulty: .advanced, category: .grinds, xpReward: 200, description: "Nose and front truck grind"),
        SkateTrick(name: "Feeble Grind", difficulty: .advanced, category: .grinds, xpReward: 200, description: "Back truck with board over"),
        SkateTrick(name: "Smith Grind", difficulty: .advanced, category: .grinds, xpReward: 220, description: "Back truck under, nose over"),
        // Airs
        SkateTrick(name: "Frontside Air", difficulty: .intermediate, category: .airs, xpReward: 150, description: "Frontside grab in transition"),
        SkateTrick(name: "Backside Air", difficulty: .intermediate, category: .airs, xpReward: 150, description: "Backside grab in transition"),
        SkateTrick(name: "Melon Grab", difficulty: .intermediate, category: .airs, xpReward: 160, description: "Backside heel grab"),
        SkateTrick(name: "Indy Grab", difficulty: .intermediate, category: .airs, xpReward: 160, description: "Frontside toe grab"),
        SkateTrick(name: "540", difficulty: .expert, category: .airs, xpReward: 500, description: "One and a half rotations"),
    ]
    
    static let onboardingTricks: [SkateTrick] = Array(allTricks.prefix(20))
}
