import Foundation

struct Phrase: Identifiable, Equatable {
    let text: String
    let tone: String
    let tip: String
    var hasSwearing = false

    var id: String { text }
}

/// The list of ways to say no, and which one belongs to which day.
///
/// This is the same list and daily order as the web app (index.html in the
/// repo root). Keep the two in step when adding phrases so the web app and
/// the iPhone app show the same no on the same day.
enum Phrases {
    static let all: [Phrase] = [
        Phrase(text: "Not this time.", tone: "Polite", tip: "Leaves the door open for next time without promising anything."),
        Phrase(text: "I'll pass.", tone: "Short", tip: "Two words. No reason owed."),
        Phrase(text: "I'm afraid not.", tone: "Polite", tip: "Sounds sorry. Isn't changing its mind."),
        Phrase(text: "No thank you.", tone: "Polite", tip: "The classic. Works on waiters, salespeople and relatives."),
        Phrase(text: "I don't think so.", tone: "Firm", tip: "Soft on the surface, a closed door underneath."),
        Phrase(text: "That's not something I can agree to.", tone: "Professional", tip: "For contracts, scope creep and anything in writing."),
        Phrase(text: "That won't work for me.", tone: "Firm", tip: "Makes it about your limits, so there's nothing to argue with."),
        Phrase(text: "I can't commit to that timeline responsibly.", tone: "Professional", tip: "For the deadline that was set before anyone asked you."),
        Phrase(text: "I'm not the right person to join this meeting, but I'm happy to share input beforehand.", tone: "Professional", tip: "Declines the invite, keeps the goodwill. Your calendar says thanks."),
        Phrase(text: "Nah.", tone: "Casual", tip: "For friends, family and anyone who's earned the shorthand."),
        Phrase(text: "I can see how that's a problem. But I can't see how it's MY problem.", tone: "Cheeky", tip: "Sympathy acknowledged. Responsibility returned to sender."),
        Phrase(text: "That's not the dumbest idea I've ever heard, but it's close.", tone: "Cheeky", tip: "Only for people who'll laugh. Know your audience."),
        Phrase(text: "Would you like a short or a long answer?\nShort answer: no.\nLong answer: noooooo.", tone: "Cheeky", tip: "Let them pick. Both roads lead to the same place."),
        Phrase(text: "If today was opposite day, I'd say 'yes'.", tone: "Cheeky", tip: "Technically a yes. Just not on any day that exists."),
        Phrase(text: "Would you like me to say no now? Or would you prefer if I said no tomorrow, after I've thought about it?", tone: "Cheeky", tip: "Offers a choice of timing. The answer is the same either way."),
        Phrase(text: "Yeah - NAH.", tone: "Casual", tip: "The Kiwi classic. The yeah is only there to soften the nah."),
        Phrase(text: "I'll do that in my 25th hour today.", tone: "Cheeky", tip: "Happy to help, as soon as the day grows an extra hour."),
        Phrase(text: "Maybe next time.", tone: "Polite", tip: "Friendly, open-ended, and commits to nothing."),
        Phrase(text: "When you have worked out a way without me, let me know.", tone: "Cheeky", tip: "Sounds supportive. Actually hands the whole thing back."),
        Phrase(text: "Rain check?", tone: "Casual", tip: "A no dressed up as a maybe later."),
        Phrase(text: "That sounds like a great job for...", tone: "Cheeky", tip: "Finish the sentence with anyone who isn't you."),
        Phrase(text: "My head says yes, my heart says no. On this one, I'm going with my heart.", tone: "Polite", tip: "Makes it sound like a hard decision, even when it wasn't."),
        Phrase(text: "That's not a good fit for me.", tone: "Professional", tip: "Clean, neutral and hard to argue with."),
        Phrase(text: "My schedule is already full.", tone: "Professional", tip: "A fact, not an excuse. No follow-up needed."),
        Phrase(text: "I'm so bummed, as my plate is so full right now.", tone: "Casual", tip: "Sounds disappointed. Plate stays exactly as full."),
        Phrase(text: "Wish I could, much hugs and good luck with it!", tone: "Polite", tip: "A no wrapped in a hug. Very hard to be annoyed at."),
        Phrase(text: "I have a prior engagement with my peace of mind.", tone: "Cheeky", tip: "The one appointment that never gets moved."),
        Phrase(text: "For fuck's sake. No!", tone: "Blunt", tip: "For when every other no on this list has already been tried.", hasSwearing: true),
        Phrase(text: "Love the idea, but I can't commit.", tone: "Polite", tip: "Compliments the idea, declines the work."),
        Phrase(text: "Cheering for you from afar on this one.", tone: "Polite", tip: "Full support, from a comfortable distance.")
    ]

    /// Positions in `all`, in the order they come up day by day. Shuffled so
    /// the same tone never lands on two days in a row.
    static let order: [Int] = [13, 22, 29, 16, 4, 14, 27, 11, 19, 3, 12, 21, 26, 24, 20, 9, 7, 25, 10, 28, 6, 8, 2, 23, 0, 15, 5, 18, 17, 1]

    /// The rotation, with phrases containing swear words left out unless the
    /// user has turned them on.
    static func rotation(includeSwearing: Bool) -> [Phrase] {
        order.map { all[$0] }.filter { includeSwearing || !$0.hasSwearing }
    }

    /// The phrase for a given calendar day.
    static func phrase(for date: Date, includeSwearing: Bool, calendar: Calendar = .current) -> Phrase {
        let list = rotation(includeSwearing: includeSwearing)
        let key = dayNumber(for: date, calendar: calendar)
        let count = list.count
        return list[((key % count) + count) % count]
    }

    /// Days since 1 January 1970 for the date as it reads on the phone's
    /// calendar. Matches the web app, so both change at local midnight.
    static func dayNumber(for date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let midnight = utc.date(from: DateComponents(year: parts.year, month: parts.month, day: parts.day))!
        return Int((midnight.timeIntervalSince1970 / 86_400).rounded(.down))
    }
}
