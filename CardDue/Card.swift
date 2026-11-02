import Foundation

struct Card: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    /// Day of the month the payment is due, 1...31.
    var dueDay: Int
    /// Month this card was last paid, such as "2026-11".
    var paidMonth: String?

    /// A card is paid only if it was checked off in the current month, so
    /// every card returns to unpaid on the 1st without any background work.
    func isPaid(on date: Date) -> Bool {
        paidMonth == Month.key(for: date)
    }

    /// The due date in the month containing `date`. A due day of 31 falls on
    /// the last day of shorter months.
    func dueDate(inMonthOf date: Date) -> Date {
        let calendar = Month.calendar
        let parts = calendar.dateComponents([.year, .month], from: date)
        let firstOfMonth = calendar.date(from: parts) ?? date
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 28
        let dayOffset = min(dueDay, daysInMonth) - 1
        return calendar.date(byAdding: .day, value: dayOffset, to: firstOfMonth) ?? date
    }

    func isOverdue(on date: Date) -> Bool {
        guard !isPaid(on: date) else { return false }
        let calendar = Month.calendar
        return calendar.startOfDay(for: dueDate(inMonthOf: date)) < calendar.startOfDay(for: date)
    }
}

enum Month {
    /// Always Gregorian, so the reset lands on the 1st whatever calendar the
    /// phone displays.
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    static func key(for date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", parts.year ?? 0, parts.month ?? 0)
    }
}
