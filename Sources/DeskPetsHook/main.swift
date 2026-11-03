import DeskPetsCore
import Foundation

// Keep the existing command path usable while sharing all session and hook logic.
let arguments = Array(CommandLine.arguments.dropFirst())
if arguments.first == "pets" {
    guard arguments.count > 1, [PetsSwitch.show, PetsSwitch.hide].contains(arguments[1]) else {
        FileHandle.standardError.write(Data("usage: deskpets-hook pets show|hide\n".utf8))
        exit(2)
    }
    DistributedNotificationCenter.default().postNotificationName(PetsSwitch.name, object: arguments[1], userInfo: nil,
                                                                 deliverImmediately: true)
} else {
    let executable = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL.resolvingSymlinksInPath()
    let bundled = executable.deletingLastPathComponent().appendingPathComponent("agent-session-bridge")
    let source = FileManager.default.isExecutableFile(atPath: bundled.path) ? bundled : executable
    exit(BridgeCLI.run(arguments, executable: source))
}
