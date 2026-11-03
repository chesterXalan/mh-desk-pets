import Foundation

public extension SessionState {
    /// The animation a pet plays for this state. Without hooks we only know "unknown", which looks idle.
    var animation: String {
        switch self {
        case .working: return "working"
        case .waiting: return "waiting"
        case .idle, .unknown, .exited: return "idle"
        }
    }
}

/// All on-disk locations, derived from one home directory so tests can use a temporary HOME.
public struct AppPaths: Sendable {
    public let home: URL

    public init(home: URL) {
        self.home = home
    }

    public static func current() -> AppPaths {
        if let home = ProcessInfo.processInfo.environment["HOME"], !home.isEmpty {
            return AppPaths(home: URL(fileURLWithPath: home, isDirectory: true))
        }
        return AppPaths(home: FileManager.default.homeDirectoryForCurrentUser)
    }

    public var support: URL { home.appendingPathComponent("Library/Application Support/DeskPets", isDirectory: true) }
    public var bridge: BridgePaths { BridgePaths(home: home) }
    public var sessions: URL { bridge.sessions }
    public var characters: URL { support.appendingPathComponent("characters", isDirectory: true) }
    public var config: URL { support.appendingPathComponent("config.json") }
    public var hookErrors: URL { bridge.hookErrors }
    public var claudeSettings: URL { home.appendingPathComponent(".claude/settings.json") }
    public var codexHooks: URL { home.appendingPathComponent(".codex/hooks.json") }
}

/// Distributed notification that shows or hides all pets (object: "show" or "hide").
public enum PetsSwitch {
    public static let name = Notification.Name("io.github.youngoman.deskpets.pets")
    public static let show = "show"
    public static let hide = "hide"
}
