//
//  CacheRow.swift
//  CacheSweep
    

import SwiftUI


struct CacheRowView: View {
    var location: CacheLocation
    @State private var showDescriptionPopover: Bool = false
    @State private var haveCopied: Bool = false
    
    var body: some View {
        HStack(spacing: 13) {
            HStack(alignment: .top, spacing: 6) {
                Text(location.name)
                    .font(.system(size: 14, weight: .semibold))

                if location.isCritical {
                    Image(.badgeAlert)
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.25))
                        .background(Color.almostClear)
                        .tooltip("This is a critical system location, it won't harm your system but it's recommended to clean it up.")
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text(formattedBytes)
                    .font(.system(size: 13, design: .monospaced))
                    .opacity(0.8)
                
                divider
                
                Image(.badgeHelp)
                    .foregroundStyle(.primary)
                    .background(Color.almostClear)
                    .pointingHandCursor()
                    .onTapGesture {
                        showDescriptionPopover.toggle()
                    }
                    .popover(isPresented: $showDescriptionPopover) {
                        Text(location.description)
                            .font(.callout)
                            .fontDesign(.rounded)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 12)
                    }
                
                divider
                
                Button(action: copyPath) {
                    Image(.copy)
                        .foregroundStyle(.primary)
                        .background(Color.almostClear)
                        .symbolEffect(.bounce, options: .nonRepeating, value: haveCopied)
                }
                .pointingHandCursor()
                .help("Copy Path")

                
                divider
                
                Button(action: clearCache) {
                    Image(.trash)
                        .foregroundStyle(.red)
                        .background(Color.almostClear)
                }
                .pointingHandCursor()
                .help("Clear Path Cache")
                
                divider
                
                Button(action: revealInFinder) {
                    Image(.chevronRight)
                        .foregroundStyle(.primary)
                        .background(Color.almostClear)
                }
                .pointingHandCursor()
                .help("Reveal in Finder")
            }
            .buttonStyle(.plain)
            .fontWeight(.medium)
            .imageScale(.large)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
    
    private var divider: some View {
        Divider().padding(.vertical, 2)
    }
    
    var formattedBytes: String {
        if location.size == 0 { return "0 KB" }
        return CacheController.shared.byteString(location.size)
    }
    
    
    func copyPath() {
        if haveCopied { return } // no need to re-trigger the animation
        let duration: TimeInterval = 2
        haveCopied = true

        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(location.path, forType: .string)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            haveCopied = false
        }
    }
    
    func clearCache() {
        Task {
            do {
                let val = try await CacheController.shared.deleteDirectoryContents(at: location.path)
                print(val)
                print("Cache cleared successfully.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func revealInFinder() {
        NSWorkspace.shared.selectFile(location.path, inFileViewerRootedAtPath: "")
    }
}
