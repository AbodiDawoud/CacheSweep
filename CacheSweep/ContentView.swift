//
//  ContentView.swift
//  CacheSweep
    

import SwiftUI

struct ContentView: View {
    @State private var cacheLocations: [CacheLocation] = CacheLocation.knownLocations
    
    @State private var isScanning = false
    @State private var isCleaning = false
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    
    @SceneStorage("freed_space") private var freedSpace: Int = 0
    @Environment(\.colorScheme) var colorScheme
    
    var totalSize: Int64 {
        cacheLocations.reduce(0) { $0 + $1.size }
    }

    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.semiBlack.ignoresSafeArea()
            
            
            // Main Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    statsSection
                    
                    
                    listSection
                }
                .padding(.horizontal, 30)
                .padding(.top, 70)
                .padding(.bottom, 90)
            }
            
            VStack {
                customTitleBar
                Spacer()
            }
            
            actionButtons
            
            
            if showToast {
                toastView
            }
        }
        .task {
            scanCaches()
        }
    }

    
    
    var customTitleBar: some View {
        HStack {
            Text("Cache Sweep")
                .font(.system(size: 20, weight: .heavy, design: .rounded))

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 25)
        .background(
            Color.semiBlack
                .ignoresSafeArea()
                .mask(alignment: .top) {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black.opacity(1.0), location: 0.50),
                            .init(color: .black.opacity(0.95), location: 0.7),
                            .init(color: .black.opacity(0.6), location: 0.85),
                            .init(color: .black.opacity(0.0), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
        )
    }
    
    
    var statsSection: some View {
        HStack(spacing: 16) {
            StatCardView(
                title: "Total Cache",
                value: CacheController.shared.byteString(totalSize),
                icon: "database",
                gradient: [Color(#colorLiteral(red: 0.1895005107, green: 0.3210249543, blue: 0.5000762939, alpha: 1)), Color(#colorLiteral(red: 0.4777941108, green: 0.5027701259, blue: 0.7055597901, alpha: 1))]
            )
            
            StatCardView(
                title: "Total Cleaned",
                value: CacheController.shared.byteString(Int64(freedSpace)),
                icon: "circle-check-big",
                gradient: [Color(#colorLiteral(red: 0.6004895568, green: 0.6718734503, blue: 0.6247107983, alpha: 1)), Color(#colorLiteral(red: 0.465059936, green: 0.5566559434, blue: 0.4440754354, alpha: 1))]
            )
            
            StatCardView(
                title: "Locations",
                value: "\(cacheLocations.count)",
                icon: "folder-tree",
                gradient: [Color(#colorLiteral(red: 0.6049374938, green: 0.4113099873, blue: 0.2904190123, alpha: 1)), Color(#colorLiteral(red: 0.6989366412, green: 0.5722115636, blue: 0.4788595438, alpha: 1))]
            )
        }
    }
    
    
    var listSection: some View {
        VStack(spacing: 11) {
            HStack {
                Text("Known Locations")
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .padding(.bottom, 3)
            
            VStack(spacing: 10) {
                ForEach(cacheLocations) { location in
                    CacheRowView(location: location)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
        }
    }
    
    
    var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: scanCaches) {
                HStack {
                    if isScanning {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Text(isScanning ? "Scanning..." : "Scan")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .font(.system(size: 14, weight: .semibold))
                .background(.thinMaterial, in: .capsule)
                .overlay {
                    Capsule().stroke(.quaternary, lineWidth: 1)
                }
            }
            .disabled(isScanning || isCleaning)
            
            Button(action: performClean) {
                HStack {
                    if isCleaning {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    
                    Text(isCleaning ? "Cleaning..." : "Clean All")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.background)
                .background(colorScheme == .light ? .black : .white, in: .capsule)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 25)
        .buttonStyle(.plain)
        .pointingHandCursor()
        .background {
            Color.semiBlack
                .mask(alignment: .top) {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black.opacity(0.2), location: 0.2),
                            .init(color: .black.opacity(0.4), location: 0.4),
                            .init(color: .black.opacity(0.92), location: 0.6),
                            .init(color: .black.opacity(0.96), location: 0.8),
                            .init(color: .black.opacity(1.0), location: 1.0),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(height: 150)
        }
    }
    
    
    var toastView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.35, green: 0.85, blue: 0.55))
            
            Text(toastMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.15, green: 0.12, blue: 0.18))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        )
        .padding(.bottom, 50)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showToast)
    }

    
    func scanCaches() {
        isScanning = true
        
        Task.detached(priority: .userInitiated) {
            let paths = await cacheLocations.map { $0.path }
            let results = await CacheController.shared.scanPaths(paths)
            
            await MainActor.run {
                for index in cacheLocations.indices {
                    let path = cacheLocations[index].path
                    cacheLocations[index].size = results[path] ?? 0
                }
                
                isScanning = false
                
                toastMessage = "Scan complete! Found " + CacheController.shared.byteString(totalSize)
                withAnimation { showToast = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showToast = false
                    }
                }
            }
        }
    }

    
    func performClean() {
        self.isCleaning = true
        let toastDuration: Double = 3
        
        Task.detached(priority: .background) {
            let availablePaths = await cacheLocations.map { $0.path }
            let (totalFreed, errors) = await CacheController.shared.cleanPaths(availablePaths)
            
            if errors.isEmpty == false {
                errors.values.forEach { print($0) }
            } else {
                print("Successfully cleaned caches! \(totalFreed) bytes freed")
            }
            
            await MainActor.run {
                self.isCleaning = false
                self.toastMessage = "Cleaned " + CacheController.shared.byteString(totalFreed) + "!"
                
                withAnimation {
                    self.showToast = true
                    self.freedSpace += Int(totalFreed)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration) {
                    withAnimation { showToast = false }
                }
            }
        }
    }
}
