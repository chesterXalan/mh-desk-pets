import AgentSessionCore
import Foundation

// Preserve the app's public model names while the implementation lives in the shared package.
public typealias Provider = AgentSessionCore.Provider
public typealias SessionState = AgentSessionCore.SessionState
public typealias PetState = SessionState
public typealias AgentSession = AgentSessionCore.AgentSession
public typealias CmuxLocation = AgentSessionCore.CmuxLocation
public typealias CmuxTree = AgentSessionCore.CmuxTree
public typealias TmuxLocation = AgentSessionCore.TmuxLocation
public typealias ProcessSnapshot = AgentSessionCore.ProcessSnapshot
public typealias ProcessTable = AgentSessionCore.ProcessTable
public typealias AgentClassifier = AgentSessionCore.AgentClassifier
public typealias ClassificationCache = AgentSessionCore.ClassificationCache
public typealias SessionScanner = AgentSessionCore.SessionScanner
public typealias HookRecord = AgentSessionCore.HookRecord
public typealias HookEvents = AgentSessionCore.HookEvents
public typealias SessionMerger = AgentSessionCore.SessionMerger
public typealias SessionNamer = AgentSessionCore.SessionNamer
public typealias HookInstaller = AgentSessionCore.HookInstaller
public typealias HookInstallerError = AgentSessionCore.HookInstallerError
public typealias BridgePaths = AgentSessionCore.BridgePaths
public typealias BridgeRuntime = AgentSessionCore.BridgeRuntime
public typealias BridgeCLI = AgentSessionCore.BridgeCLI

public extension HookInstaller {
    init(paths: AppPaths, hookExecutable: String, now: @escaping () -> Date = Date.init) {
        self.init(paths: paths.bridge, hookExecutable: hookExecutable, now: now)
    }
}
