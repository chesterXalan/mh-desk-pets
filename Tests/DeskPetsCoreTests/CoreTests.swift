import Foundation
import Testing
@testable import DeskPetsCore

private func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("deskpets-tests-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

@Suite struct ConfigTests {
    @Test func roundTripsAndToleratesMissingFields() throws {
        let directory = try temporaryDirectory()
        let url = directory.appendingPathComponent("nested/config.json")
        var config = AppConfig(showPets: false, petSize: 128)
        config.bindings = [PetBinding(provider: .codex, cwd: "/p", character: "ghost", pid: 3, pidStart: 4, x: 10, y: 20)]
        config.rememberCharacter(from: config.bindings[0])
        try config.save(to: url)
        #expect(AppConfig.load(from: url) == config)

        try Data(#"{"petSize": 64}"#.utf8).write(to: url)
        let partial = AppConfig.load(from: url)
        #expect(partial.petSize == 64 && partial.showPets && partial.bindings.isEmpty)
        #expect(partial.language == .system && partial.directoryPets.isEmpty)

        try Data("not json".utf8).write(to: url)
        #expect(AppConfig.load(from: url) == AppConfig())
    }

    @Test func reattachesBindingAfterRestart() {
        var config = AppConfig(bindings: [PetBinding(provider: .claude, cwd: "/work/app", character: "cat",
                                                    pid: 100, pidStart: 1000, x: 12, y: 34)])
        let restarted = [
            AgentSession(provider: .codex, pid: 300, startTime: 3000, cwd: "/work/app"),
            AgentSession(provider: .claude, pid: 200, startTime: 2000, cwd: "/work/app"),
            AgentSession(provider: .claude, pid: 250, startTime: 2500, cwd: "/work/app"),
        ]
        let resolved = BindingResolver.resolve(&config, sessions: restarted, characters: ["cat", "ghost", "dragon"], choose: { $0.first })
        #expect(config.bindings.map(\.character) == ["cat", "ghost", "dragon"])
        #expect(resolved[config.bindings[0].id] == restarted[1].id)
        #expect(config.bindings[0].pid == 200 && config.bindings[0].pidStart == 2000)
        #expect(config.bindings[0].x == 12 && config.bindings[0].y == 34)
        #expect(config.directoryPets["/work/app"]?.character == "cat")
    }

    @Test func exactMatchesAreNotStolen() {
        let a = PetBinding(provider: .claude, cwd: "/w", character: "cat", pid: 2, pidStart: 20)
        let b = PetBinding(provider: .claude, cwd: "/w", character: "ghost", pid: 99, pidStart: 1)
        var config = AppConfig(bindings: [b, a])
        let sessions = [AgentSession(provider: .claude, pid: 1, startTime: 10, cwd: "/w"),
                        AgentSession(provider: .claude, pid: 2, startTime: 20, cwd: "/w")]
        let resolved = BindingResolver.resolve(&config, sessions: sessions, characters: ["cat", "ghost"], choose: { $0.first })
        #expect(resolved[a.id] == sessions[1].id)
        #expect(config.bindings[0].character == "ghost" && config.bindings[0].pid == 1)
        #expect(config.bindings[1] == a)
        #expect(!config.bindings.contains { $0.id == b.id })
    }

    @Test func endedBindingsBecomeDirectoryPreferences() {
        var config = AppConfig(bindings: [PetBinding(provider: .claude, cwd: "/gone", character: "cat", pid: 5, pidStart: 5)])
        let session = AgentSession(provider: .codex, pid: 6, startTime: 6, cwd: "/other")
        let resolved = BindingResolver.resolve(&config, sessions: [session], characters: ["cat", "ghost"], choose: { $0.last })
        #expect(config.bindings.count == 1 && config.bindings[0].pid == 6)
        #expect(resolved[config.bindings[0].id] == session.id)
        #expect(config.directoryPets["/gone"]?.character == "cat")
        #expect(config.directoryPets["/other"]?.character == "ghost")
    }
}

@Suite struct CharacterLibraryTests {
    private func gif(in directory: URL, name: String) throws -> URL {
        let url = directory.appendingPathComponent(name)
        try Data("GIF89a-fake".utf8).write(to: url)
        return url
    }

    @Test func sortsByNumericEMIDWithLegacyAndCustomCharactersPreserved() throws {
        let root = try temporaryDirectory()
        let entries: [(String, Int?, Bool)] = [
            ("a-late", 160, true), ("b-early", 2, true), ("c-middle", 11, true),
            ("d-same-id", 2, true), ("a-legacy", nil, true),
            ("custom-10", nil, false), ("custom-2", nil, false),
        ]
        for (name, emID, builtIn) in entries {
            let directory = root.appendingPathComponent("\(builtIn ? "builtin" : "custom")/\(name)")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            _ = try gif(in: directory, name: "idle.gif")
            if let emID {
                try Data("{\"emID\":\(emID)}".utf8).write(to: directory.appendingPathComponent("character.json"))
            }
        }
        let library = CharacterLibrary(builtInRoot: root.appendingPathComponent("builtin"),
                                       customRoot: root.appendingPathComponent("custom"))
        #expect(library.list().map(\.name) == [
            "b-early", "d-same-id", "c-middle", "a-late", "a-legacy", "custom-2", "custom-10",
        ])
        #expect(library.character(named: "a-late")?.emID == 160)
        #expect(library.character(named: "a-legacy")?.emID == nil)
    }

    @Test func importsListsAndDeletes() throws {
        let root = try temporaryDirectory()
        let builtIn = root.appendingPathComponent("builtin/cat", isDirectory: true)
        try FileManager.default.createDirectory(at: builtIn, withIntermediateDirectories: true)
        _ = try gif(in: builtIn, name: "idle.gif")
        let library = CharacterLibrary(builtInRoot: root.appendingPathComponent("builtin"), customRoot: root.appendingPathComponent("custom"))

        let idle = try gif(in: root, name: "a.gif")
        let character = try library.importCharacter(name: "  Mochi ", idle: idle)
        #expect(character.name == "Mochi")
        #expect(character.displayScale == 1)
        #expect(library.list().map(\.name) == ["cat", "Mochi"])
        // Missing optional animations fall back to idle.
        #expect(character.gif(for: .working).lastPathComponent == "idle.gif")

        #expect(throws: CharacterError.alreadyExists("Mochi")) { try library.importCharacter(name: "Mochi", idle: idle) }
        #expect(throws: CharacterError.invalidName) { try library.importCharacter(name: "../x", idle: idle) }
        let text = root.appendingPathComponent("b.gif")
        try Data("hello".utf8).write(to: text)
        #expect(throws: CharacterError.notAGIF("b.gif")) { try library.importCharacter(name: "Bad", idle: text) }

        #expect(throws: CharacterError.builtIn) { try library.delete(library.character(named: "cat")!) }
        try library.delete(character)
        #expect(library.list().map(\.name) == ["cat"])
    }

    @Test(arguments: [
        (#"{"displayScale":1.2}"#, 1.2),
        (#"{"displayScale":0}"#, 1.0),
        (#"{"displayScale":3}"#, 1.0),
        ("{}", 1.0),
        ("broken", 1.0),
    ])
    func readsCharacterScale(options: String, expected: Double) throws {
        let root = try temporaryDirectory()
        let directory = root.appendingPathComponent("custom/Ice")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        _ = try gif(in: directory, name: "idle.gif")
        try Data(options.utf8).write(to: directory.appendingPathComponent("character.json"))
        let library = CharacterLibrary(builtInRoot: nil, customRoot: root.appendingPathComponent("custom"))
        #expect(library.character(named: "Ice")?.displayScale == expected)
    }
}

@Suite struct CmuxControlTests {
    @Test func focusRunsSelectThenFocusPanel() {
        var calls: [[String]] = []
        let location = CmuxLocation(workspaceId: "W", surfaceId: "S", cli: "/bin/cmux")
        let ok = CmuxControl.focus(location) { cli, args in
            calls.append([cli] + args)
            return Data()
        }
        #expect(ok)
        #expect(calls == [["/bin/cmux", "select-workspace", "--workspace", "W"],
                          ["/bin/cmux", "focus-panel", "--panel", "S", "--workspace", "W"]])
        #expect(!CmuxControl.focus(location) { _, _ in nil })
    }

}
