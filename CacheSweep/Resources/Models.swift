//
//  Models.swift
//  CacheSweep
    

import Foundation

fileprivate let __HOME_DIC = FileManager.default.homeDirectoryForCurrentUser.path()

struct CacheLocation: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let description: String
    var size: Int64 = 0
    let isCritical: Bool
}


enum CacheError: LocalizedError {
    case pathNotFound
    case invalidOutput
    case commandFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .pathNotFound:
            return "The specified path could not be found."
        case .invalidOutput:
            return "Failed to parse output from shell command."
        case .commandFailed(let message):
            return "Shell command failed: \(message)"
        }
    }
}




extension CacheLocation {
    static var knownLocations: [CacheLocation] {[
        CacheLocation(
            path: "\(__HOME_DIC)/Library/Containers/com.apple.CoreDevice.CoreDeviceService/Data/Library/Caches/AppInstallationBinaryDeltas",
            name: "Core Device Service",
            description: "Caches for CoreDevice service, used for managing device connections and app installations (mainly for development).",
            isCritical: false
        ),
        CacheLocation(
            path: "\(__HOME_DIC)/Library/Containers/com.apple.wallpaper.agent/Data/Library/Caches",
            name: "Wallpaper Agent",
            description: "Wallpaper image cache and related data used by macOS wallpaper services.",
            isCritical: false
        ),
        CacheLocation(
            path: "\(__HOME_DIC)/Library/Caches",
            name: "User Caches",
            description: "General cache directory for user applications and system agents.",
            isCritical: false
        ),
        
        // --- System-level caches ---
        CacheLocation(
            path: "/Library/Caches",
            name: "System Caches",
            description: "Global cache directory used by system daemons and applications.",
            isCritical: false
        ),
        CacheLocation(
            path: "/Library/HTTPStorages",
            name: "HTTP Storages",
            description: "Caches for HTTP requests, cookies, and URL session data used by system services and apps.",
            isCritical: false
        ),
        CacheLocation(
            path: "/Library/Application Support/com.apple.idleassetsd",
            name: "Idle Assets",
            description: "Caches used by the IdleAssets daemon for preloaded background assets.",
            isCritical: false
        ),
        
        // --- Logs and diagnostics ---
        CacheLocation(
            path: "/Library/Logs",
            name: "System Logs",
            description: "System and application log files for all users.",
            isCritical: true
        ),
        CacheLocation(
            path: "/Library/Preferences/Logging",
            name: "Logging Preferences",
            description: "System logging configuration and preference data.",
            isCritical: true
        ),
        CacheLocation(
            path: "/private/var/log",
            name: "Core System Logs",
            description: "Primary system log directory containing kernel, install, and diagnostic logs.",
            isCritical: true
        ),
        CacheLocation(
            path: "/private/var/db/diagnostics",
            name: "Diagnostics Reports",
            description: "Diagnostic and analytics reports collected by macOS.",
            isCritical: true
        ),
        CacheLocation(
            path: "/private/var/db/powerlog",
            name: "Power Logs",
            description: "Logs related to power management and battery usage.",
            isCritical: false
        ),
        
        // --- Temporary data ---
        CacheLocation(
            path: "/private/var/tmp",
            name: "Temporary Files",
            description: "Temporary storage used by system and apps; cleared periodically.",
            isCritical: false
        ),
        
        // --- Optional but useful ---
        CacheLocation(
            path: "/System/Library/Caches",
            name: "System Library Caches",
            description: "Caches used by macOS system components; should not be modified manually.",
            isCritical: true
        ),
    ]}
}
