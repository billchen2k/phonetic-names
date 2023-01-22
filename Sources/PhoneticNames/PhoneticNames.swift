import ArgumentParser
import Foundation

@main
struct PhoneticNames: ParsableCommand {

    @Flag(name: [.customShort("d"), .customLong("dry")], help: "Dry run without modifying the contacts.")
    var dryRun = false

    @Flag(name: .shortAndLong, help: "Force update all phonetic names, even if the phonetic names already exist.")
    var force = false

    @Flag(name: .shortAndLong, help: "Clean all contact's phonetic names.")
    var clean = false

    mutating public func run() throws {
        var cpn = ContactPhoneticNames(dryRun: dryRun, force: force)
        if clean && force {
            print("Error: cannot use -f and -c at the same time.")
            return
        }
        if clean {
            cpn.runClean()
        } else {
            cpn.runFill()
        }
    }
}
