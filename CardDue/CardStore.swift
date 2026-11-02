import Foundation
import Observation

@MainActor
@Observable
final class CardStore {
    private struct SavedState: Codable {
        var cards: [Card]
        var remindersEnabled: Bool
        var reminderDaysBefore: Int
    }

    private(set) var cards: [Card] = []
    private(set) var now = Date()

    var remindersEnabled = true {
        didSet { saveAndReschedule() }
    }
    var reminderDaysBefore = 1 {
        didSet { saveAndReschedule() }
    }

    private let fileURL = URL.documentsDirectory.appending(path: "cards.json")
    private var isLoading = false

    init() {
        load()
    }

    var unpaidCards: [Card] {
        cards
            .filter { !$0.isPaid(on: now) }
            .sorted { $0.dueDate(inMonthOf: now) < $1.dueDate(inMonthOf: now) }
    }

    var paidCards: [Card] {
        cards
            .filter { $0.isPaid(on: now) }
            .sorted { $0.dueDate(inMonthOf: now) < $1.dueDate(inMonthOf: now) }
    }

    func save(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }
        saveAndReschedule()
    }

    func delete(_ card: Card) {
        cards.removeAll { $0.id == card.id }
        saveAndReschedule()
    }

    func togglePaid(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].paidMonth = card.isPaid(on: now) ? nil : Month.key(for: now)
        saveAndReschedule()
    }

    /// Call when the app opens and when the day changes, so the list resets
    /// on the 1st even if the app was left open overnight.
    func refresh() {
        now = Date()
        reschedule()
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }
        guard let data = try? Data(contentsOf: fileURL),
              let state = try? JSONDecoder().decode(SavedState.self, from: data) else { return }
        cards = state.cards
        remindersEnabled = state.remindersEnabled
        reminderDaysBefore = state.reminderDaysBefore
    }

    private func saveAndReschedule() {
        guard !isLoading else { return }
        let state = SavedState(
            cards: cards,
            remindersEnabled: remindersEnabled,
            reminderDaysBefore: reminderDaysBefore
        )
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: fileURL, options: .atomic)
        }
        reschedule()
    }

    private func reschedule() {
        let cards = cards
        let enabled = remindersEnabled
        let daysBefore = reminderDaysBefore
        Task {
            await Reminders.reschedule(cards: cards, enabled: enabled, daysBefore: daysBefore)
        }
    }
}
