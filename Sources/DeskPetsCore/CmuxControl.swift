import AgentSessionCore
import Foundation

public enum CmuxControl {
    public static let defaultCLI = "/Applications/cmux.app/Contents/Resources/bin/cmux"
    public static let bundleIdentifier = "com.cmuxterm.app"

    /// Selects the session's workspace and focuses its tab. Returns false when cmux refused.
    @discardableResult
    public static func focus(_ location: CmuxLocation, run: (String, [String]) -> Data? = SessionNamer.run) -> Bool {
        let cli = location.cli ?? defaultCLI
        guard run(cli, ["select-workspace", "--workspace", location.workspaceId]) != nil else { return false }
        return run(cli, ["focus-panel", "--panel", location.surfaceId, "--workspace", location.workspaceId]) != nil
    }
}
