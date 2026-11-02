import Combine
import SwiftUI

struct ContentView: View {
    @Environment(CardStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    @State private var editingCard: Card?
    @State private var isAddingCard = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if store.cards.isEmpty {
                    emptyState
                } else {
                    cardList
                }
            }
            .navigationTitle(store.now.formatted(.dateTime.month(.wide)))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gearshape") {
                        isShowingSettings = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Card", systemImage: "plus") {
                        isAddingCard = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingCard) {
            EditCardView(card: nil)
        }
        .sheet(item: $editingCard) { card in
            EditCardView(card: card)
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { store.refresh() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
            store.refresh()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Cards Yet", systemImage: "creditcard")
        } description: {
            Text("Add a card and its due day. Every card returns to unpaid on the 1st of the month.")
        } actions: {
            Button("Add Card") { isAddingCard = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private var cardList: some View {
        List {
            if !store.unpaidCards.isEmpty {
                Section("To Pay") {
                    ForEach(store.unpaidCards) { row(for: $0) }
                }
            }
            if !store.paidCards.isEmpty {
                Section("Paid") {
                    ForEach(store.paidCards) { row(for: $0) }
                }
            }
        }
    }

    private func row(for card: Card) -> some View {
        CardRow(card: card, now: store.now) {
            store.togglePaid(card)
        } onEdit: {
            editingCard = card
        }
        .swipeActions {
            Button("Delete", systemImage: "trash", role: .destructive) {
                store.delete(card)
            }
        }
    }
}

private struct CardRow: View {
    let card: Card
    let now: Date
    let onToggle: () -> Void
    let onEdit: () -> Void

    private var isPaid: Bool { card.isPaid(on: now) }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isPaid ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isPaid ? Color.green : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isPaid ? "Mark \(card.name) as unpaid" : "Mark \(card.name) as paid")

            Button(action: onEdit) {
                HStack {
                    Text(card.name)
                        .strikethrough(isPaid)
                        .foregroundStyle(isPaid ? .secondary : .primary)
                    Spacer()
                    Text(status)
                        .font(.subheadline)
                        .foregroundStyle(card.isOverdue(on: now) ? Color.red : Color.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var status: String {
        let dueDate = card.dueDate(inMonthOf: now)
        let dateText = dueDate.formatted(.dateTime.month(.abbreviated).day())
        if isPaid { return dateText }
        if card.isOverdue(on: now) { return "Overdue, \(dateText)" }

        let calendar = Month.calendar
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: dueDate)
        ).day ?? 0
        switch days {
        case 0: return "Due today"
        case 1: return "Due tomorrow"
        default: return "\(dateText), in \(days) days"
        }
    }
}
