import Foundation
import MultipeerConnectivity
import SwiftUI
import UIKit

// MARK: - Nearby favorites payload
// IDs + titles only. No images go over the wire, so sends stay small and fast.

struct SharedAnime: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
}

struct SharedFavorites: Codable {
    let sender: String
    let items: [SharedAnime]
}

// MARK: - Peer-to-peer session
// Advertises and browses at the same time, so any two nearby devices running
// BankaiBuddy find each other. Invitations are auto-accepted: this is a
// friends feature over a proximity-limited link, and one tap should just work.
// The phones-close gesture itself is already delivered by the system share
// sheet's AirDrop — no custom UWB / Nearby Interaction work lives here.

@Observable
final class NearbyShareSession: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    static let serviceType = "bankaibuddy"

    private(set) var foundPeers: [MCPeerID] = []
    private(set) var connectedPeers: [MCPeerID] = []
    private(set) var pendingPeer: MCPeerID?
    private(set) var received: SharedFavorites?
    private(set) var sentPeerIDs: Set<MCPeerID> = []
    private(set) var status: String = "Looking for nearby friends…"

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    private var pendingFavorites: [Anime] = []

    override init() {
        super.init()
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        advertiser.delegate = self
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser.delegate = self
    }

    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }

    /// One tap to share: invites the peer if needed, then sends once connected.
    func send(favorites: [Anime], to peer: MCPeerID) {
        if connectedPeers.contains(peer) {
            sendNow(favorites: favorites, to: peer)
        } else {
            pendingPeer = peer
            pendingFavorites = favorites
            status = "Connecting to \(peer.displayName)…"
            browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
        }
    }

    private func sendNow(favorites: [Anime], to peer: MCPeerID) {
        let payload = SharedFavorites(
            sender: myPeerID.displayName,
            items: favorites.map { SharedAnime(id: $0.id, title: $0.title) }
        )
        guard let data = try? JSONEncoder().encode(payload) else { return }
        do {
            try session.send(data, toPeers: [peer], with: .reliable)
            sentPeerIDs.insert(peer)
            status = "Sent favorites to \(peer.displayName)."
        } catch {
            status = "Couldn't send to \(peer.displayName)."
        }
    }

    // MARK: - MCSessionDelegate

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if !connectedPeers.contains(peerID) { connectedPeers.append(peerID) }
            if peerID == pendingPeer {
                pendingPeer = nil
                sendNow(favorites: pendingFavorites, to: peerID)
                pendingFavorites = []
            } else {
                status = "\(peerID.displayName) connected."
            }
        case .notConnected:
            connectedPeers.removeAll { $0 == peerID }
            foundPeers.removeAll { $0 == peerID }
            if peerID == pendingPeer {
                pendingPeer = nil
                pendingFavorites = []
                status = "Couldn't connect to \(peerID.displayName)."
            }
        case .connecting:
            status = "Connecting to \(peerID.displayName)…"
        @unknown default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let decoded = try? JSONDecoder().decode(SharedFavorites.self, from: data) else { return }
        received = decoded
        status = "Got favorites from \(peerID.displayName)."
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {}

    // MARK: - MCNearbyServiceAdvertiserDelegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: any Error) {
        status = "Nearby sharing couldn't start."
    }

    // MARK: - MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if !foundPeers.contains(peerID) { foundPeers.append(peerID) }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        foundPeers.removeAll { $0 == peerID }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: any Error) {
        status = "Nearby sharing couldn't start."
    }
}

// MARK: - Nearby share sheet

struct NearbyShareView: View {
    let favorites: [Anime]
    @State private var shareSession = NearbyShareSession()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(shareSession.status)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Nearby friends") {
                    if shareSession.foundPeers.isEmpty {
                        Text("No friends nearby yet. Keep this open — friends running BankaiBuddy nearby will show up here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(shareSession.foundPeers, id: \.self) { peer in
                            HStack {
                                Label(peer.displayName, systemImage: "iphone")
                                Spacer()
                                if shareSession.sentPeerIDs.contains(peer) {
                                    Label("Sent", systemImage: "checkmark")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(BrandKit.mint)
                                } else if shareSession.pendingPeer == peer {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Button("Send favorites") {
                                        shareSession.send(favorites: favorites, to: peer)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(BrandKit.indigo)
                                    .controlSize(.small)
                                }
                            }
                        }
                    }
                }

                if let received = shareSession.received {
                    Section("From \(received.sender)") {
                        if received.items.isEmpty {
                            Text("Their favorites list is empty.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(received.items) { item in
                                Label(item.title, systemImage: "heart.fill")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Share Nearby")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { shareSession.start() }
            .onDisappear { shareSession.stop() }
        }
    }
}
