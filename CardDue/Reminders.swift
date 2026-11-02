import Foundation
import UserNotifications

enum Reminders {
    /// iOS keeps at most 64 pending notifications per app.
    private static let pendingLimit = 64
    private static let monthsAhead = 6
    private static let reminderHour = 9

    private struct Reminder {
        let card: Card
        let dueDate: Date
        let fireDate: Date
    }

    static func reschedule(cards: [Card], enabled: Bool, daysBefore: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard enabled, !cards.isEmpty else { return }

        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        guard granted else { return }

        let reminders = upcoming(cards: cards, daysBefore: daysBefore, from: Date())
        for reminder in reminders.prefix(pendingLimit) {
            try? await center.add(request(for: reminder, daysBefore: daysBefore))
        }
    }

    private static func upcoming(cards: [Card], daysBefore: Int, from now: Date) -> [Reminder] {
        let calendar = Month.calendar
        var reminders: [Reminder] = []
        for card in cards {
            for offset in 0..<monthsAhead {
                guard let month = calendar.date(byAdding: .month, value: offset, to: now) else { continue }
                let dueDate = card.dueDate(inMonthOf: month)
                guard !card.isPaid(on: dueDate),
                      let day = calendar.date(byAdding: .day, value: -daysBefore, to: dueDate),
                      let fireDate = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: day),
                      fireDate > now else { continue }
                reminders.append(Reminder(card: card, dueDate: dueDate, fireDate: fireDate))
            }
        }
        return reminders.sorted { $0.fireDate < $1.fireDate }
    }

    private static func request(for reminder: Reminder, daysBefore: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = reminder.card.name
        switch daysBefore {
        case 0: content.body = "Payment is due today."
        case 1: content.body = "Payment is due tomorrow."
        default: content.body = "Payment is due in \(daysBefore) days."
        }
        content.sound = .default

        let parts = Month.calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        let identifier = "\(reminder.card.id)-\(Month.key(for: reminder.dueDate))"
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
}
