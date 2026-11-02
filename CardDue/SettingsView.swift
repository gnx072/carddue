import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(CardStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var notificationsDenied = false

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            Form {
                Section {
                    Toggle("Payment reminders", isOn: $store.remindersEnabled)
                    if store.remindersEnabled {
                        Picker("Remind me", selection: $store.reminderDaysBefore) {
                            Text("On the due day").tag(0)
                            Text("1 day before").tag(1)
                            Text("2 days before").tag(2)
                            Text("3 days before").tag(3)
                            Text("1 week before").tag(7)
                        }
                    }
                } footer: {
                    if notificationsDenied {
                        Text("Notifications are turned off for CardDue. You can allow them in the iOS Settings app.")
                    } else {
                        Text("Reminders arrive at 9:00 AM and stop once a card is marked as paid.")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                notificationsDenied = settings.authorizationStatus == .denied
            }
        }
    }
}
