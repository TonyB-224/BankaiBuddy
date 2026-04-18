import Foundation
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
@MainActor
final class LibraryStore {
    private(set) var watched: [Anime] = []
    private(set) var watching: [Anime] = []
    private(set) var favorites: [Anime] = []

    private var listeners: [ListenerRegistration] = []
    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                self.detach()
                if let uid = user?.uid {
                    self.attach(uid: uid)
                } else {
                    self.watched = []
                    self.watching = []
                    self.favorites = []
                }
            }
        }
    }


    func list(_ kind: ListKind) -> [Anime] {
        switch kind {
        case .watched: watched
        case .watching: watching
        case .favorites: favorites
        }
    }

    func contains(_ anime: Anime, in kind: ListKind) -> Bool {
        list(kind).contains(where: { $0.id == anime.id })
    }

    func toggle(_ anime: Anime, in kind: ListKind) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let doc = Firestore.firestore()
            .collection("users").document(uid)
            .collection(kind.rawValue).document(String(anime.id))

        do {
            if contains(anime, in: kind) {
                try await doc.delete()
            } else {
                try doc.setData(from: anime)
            }
        } catch {
            print("toggle error:", error.localizedDescription)
        }
    }

    private func attach(uid: String) {
        let db = Firestore.firestore()
        for kind in ListKind.allCases {
            let ref = db.collection("users").document(uid).collection(kind.rawValue)
            let listener = ref.addSnapshotListener { [weak self] snapshot, _ in
                guard let self, let docs = snapshot?.documents else { return }
                let items = docs.compactMap { try? $0.data(as: Anime.self) }
                Task { @MainActor in
                    self.assign(items, to: kind)
                }
            }
            listeners.append(listener)
        }
    }

    private func detach() {
        listeners.forEach { $0.remove() }
        listeners = []
    }

    private func assign(_ items: [Anime], to kind: ListKind) {
        switch kind {
        case .watched: watched = items
        case .watching: watching = items
        case .favorites: favorites = items
        }
    }
}
