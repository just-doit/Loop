//
//  UpdateView.swift
//  Loop
//
//  Created by Kami on 15/06/2024.
//

import Luminare
import SwiftUI

struct UpdateView: View {
    @Environment(\.tintColor) var tintColor
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var updater = AppDelegate.updater
    @State var isInstalling: Bool = false
    @State var readyToRestart: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                theLoopTimesView()
                versionChangeView()
            }
            .padding([.top, .horizontal], 12)
            .padding(.bottom, 10)

            changelogView()
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            HStack {
                Button("Remind me later") {
                    AppDelegate.updater.dismissWindow()
                }

                Button {
                    if readyToRestart {
                        AppDelegate.relaunch()
                    }

                    withAnimation(.smooth(duration: 0.25)) {
                        isInstalling = true
                    }
                    Task {
                        await AppDelegate.updater.installUpdate()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.smooth(duration: 0.1)) {
                                isInstalling = false
                            }
                            withAnimation(.smooth(duration: 0.25)) {
                                readyToRestart = true
                            }
                        }
                    }
                } label: {
                    ZStack {
                        if isInstalling {
                            Capsule()
                                .frame(maxWidth: .infinity)
                                .frame(height: 5)
                                .foregroundStyle(.quinary)
                                .overlay {
                                    GeometryReader { geo in
                                        Capsule()
                                            .foregroundStyle(tintColor())
                                            .frame(width: CGFloat(updater.progressBar) * geo.size.width)
                                            .animation(.smooth(duration: 0.8), value: updater.progressBar)
                                            .shadow(color: tintColor().opacity(0.1), radius: 12)
                                            .shadow(color: tintColor().opacity(0.4), radius: 6)
                                            .shadow(color: tintColor(), radius: 1)
                                    }
                                }
                                .padding(.horizontal, 4)
                        }

                        Text(isInstalling ? "               " : readyToRestart ? "Restart to complete" : "Install")
                            .contentTransition(.numericText())
                            .opacity(isInstalling ? 0 : 1)
                    }
                }
                .allowsHitTesting(!isInstalling)
            }
            .buttonStyle(LuminareCompactButtonStyle())
            .padding(12)
            .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
            .overlay {
                VStack {
                    Divider()
                    Spacer()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 570, height: 480)
    }

    func theLoopTimesView() -> some View {
        ZStack {
            if colorScheme == .dark {
                TheLoopTimes()
                    .fill(
                        .shadow(.inner(color: .black.opacity(0.1), radius: 3))
                            .shadow(.inner(color: .black.opacity(0.3), radius: 5, y: 3))
                    )
                    .foregroundStyle(.primary.opacity(0.7))
                    .blendMode(.overlay)
            } else {
                TheLoopTimes()
                    .foregroundStyle(.primary.opacity(0.7))
                    .blendMode(.overlay)

                TheLoopTimes()
                    .fill(
                        .shadow(.inner(color: .black.opacity(0.1), radius: 3))
                            .shadow(.inner(color: .black.opacity(0.3), radius: 5, y: 3))
                    )
                    .blendMode(.overlay)
            }

            TheLoopTimes()
                .stroke(.primary.opacity(0.1), lineWidth: 1)
                .blendMode(.luminosity)
        }
        .aspectRatio(883.88 / 135.53, contentMode: .fit)
        .frame(width: 450)
    }

    func versionChangeView() -> some View {
        ZStack {
            if colorScheme == .dark {
                HStack {
                    Text(Bundle.main.appVersion)
                    Image(systemName: "arrow.right")
                    Text(updater.availableReleases.first?.tagName ?? "Unknown")
                }
                .foregroundStyle(.primary.opacity(0.7))
                .blendMode(.overlay)
            } else {
                HStack {
                    Text(Bundle.main.appVersion)
                    Image(systemName: "arrow.right")
                    Text(updater.availableReleases.first?.tagName ?? "Unknown")
                }
                .foregroundStyle(.primary.opacity(0.7))
                .blendMode(.overlay)

                HStack {
                    Text(Bundle.main.appVersion)
                    Image(systemName: "arrow.right")
                    Text(updater.availableReleases.first?.tagName ?? "Unknown")
                }
                .blendMode(.overlay)
            }
        }
    }

    func changelogView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(updater.changelog, id: \.title) { item in
                    ChangelogSectionView(item: item)
                }
            }
            .padding(.top, 10)
            .padding(12)
        }
    }
}

struct ChangelogSectionView: View {
    let item: (title: String, body: [String])
    @State var isExpanded = false

    var body: some View {
        LuminareSection {
            Button {
                withAnimation(.smooth(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(._12PxChevronRight)
                        .bold()
                        .rotationEffect(isExpanded ? .degrees(90) : .zero)

                    Text(LocalizedStringKey(item.title))
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .frame(height: 34)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(item.body, id: \.self) { line in
                    let emoji = line.prefix(1)
                    let note = line
                        .suffix(line.count - 1)
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    HStack(spacing: 8) {
                        Text(emoji)
                        Text(LocalizedStringKey(note))
                            .lineSpacing(1.1)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(minHeight: 34)
                }
            }
        }
    }
}
