import SwiftUI

struct EditCardView: View {
    @Environment(CardStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let card: Card?
    @State private var name: String
    @State private var dueDay: Int

    init(card: Card?) {
        self.card = card
        _name = State(initialValue: card?.name ?? "")
        _dueDay = State(initialValue: card?.dueDay ?? 1)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name, such as Travel Card", text: $name)
                    Picker("Due day", selection: $dueDay) {
                        ForEach(1...31, id: \.self) { Text("\($0)").tag($0) }
                    }
                } footer: {
                    Text("Use a nickname. Never enter your card number here. In shorter months, a later due day moves to the last day of the month.")
                }

                if let card {
                    Section {
                        Button("Delete Card", role: .destructive) {
                            store.delete(card)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(card == nil ? "Add Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private func save() {
        var updated = card ?? Card(name: trimmedName, dueDay: dueDay)
        updated.name = trimmedName
        updated.dueDay = dueDay
        store.save(updated)
        dismiss()
    }
}
