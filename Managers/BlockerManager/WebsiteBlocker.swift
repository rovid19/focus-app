import Foundation

class WebsiteBlocker {
    static let shared = WebsiteBlocker()
    private init() {}

    private let pfRulesFilePath = "/private/etc/.focus-block.conf"
    private let hostsFilePath = "/etc/hosts"

    // MARK: - Public API

    func block(domains: [String]) {
        // Expand domains to include "www." versions if not already present
        var expandedDomains: [String] = []
        for domain in domains {
            expandedDomains.append(domain)
            if !domain.hasPrefix("www.") {
                expandedDomains.append("www.\(domain)")
            }
        }

        blockInHosts(domains: expandedDomains)
        blockInPF(domains: expandedDomains)
    }

    func unblock() {
        unblockHosts()
        unblockPF()
    }

    // MARK: - /etc/hosts Blocking

    private func blockInHosts(domains: [String]) {
        do {
            var hostsContent = try String(contentsOfFile: hostsFilePath, encoding: .utf8)
            // Remove old focus-app entries first
            hostsContent = hostsContent
                .split(separator: "\n")
                .filter { !$0.contains("# focus-app-block") }
                .joined(separator: "\n")

            for domain in domains {
                hostsContent += "\n127.0.0.1 \(domain) # focus-app-block"
            }

            try hostsContent.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)

            // Flush DNS cache
            _ = runShell("dscacheutil -flushcache; killall -HUP mDNSResponder")

            print("Hosts blocking applied for: \(domains)")
        } catch {
            print("Failed to modify /etc/hosts: \(error)")
        }
    }

    private func unblockHosts() {
        do {
            var hostsContent = try String(contentsOfFile: hostsFilePath, encoding: .utf8)
            hostsContent = hostsContent
                .split(separator: "\n")
                .filter { !$0.contains("# focus-app-block") }
                .joined(separator: "\n")
            try hostsContent.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)

            _ = runShell("dscacheutil -flushcache; killall -HUP mDNSResponder")

            print("Hosts blocking removed.")
        } catch {
            print("Failed to restore /etc/hosts: \(error)")
        }
    }

    // MARK: - PF Firewall Blocking

    private func blockInPF(domains: [String]) {
        var ipRules: [String] = []

        for domain in domains {
            let ips = resolveIPs(for: domain)
            for ip in ips {
                ipRules.append("block drop quick on en0 from any to \(ip)")
            }
        }

        let rulesText = ipRules.joined(separator: "\n")

        do {
            try rulesText.write(toFile: pfRulesFilePath, atomically: true, encoding: .utf8)
            _ = runShell("pfctl -f \(pfRulesFilePath)")
            _ = runShell("pfctl -E")
            print("PF blocking applied for: \(domains)")
        } catch {
            print("Failed to write PF rules: \(error)")
        }
    }

  private func unblockPF() {
    // Option 1: Reload default system rules
    _ = runShell("pfctl -f /etc/pf.conf")
    _ = runShell("pfctl -d") // disable packet filter
    print("PF restored to default rules.")
}


    // MARK: - Utilities

    private func resolveIPs(for domain: String) -> [String] {
        let output = runShell("dig +short \(domain)")
        return output
            .split(separator: "\n")
            .map { String($0) }
            .filter {
                !$0.isEmpty &&
                $0.range(of: #"^\d+\.\d+\.\d+\.\d+$"#, options: .regularExpression) != nil
            }
    }

    @discardableResult
    private func runShell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
