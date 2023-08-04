import Foundation

extension String {
    static func getDayAddition(int: Int) -> String {
        let preLastDigit = int % 100 / 10
        if preLastDigit == 1 { return "дней" }
        switch (int % 10) {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
    
    var weekDay: WeekDay? {
        switch self {
        case "monday":
            return .monday
        case "tuesday":
            return .tuesday
        case "wednesday":
            return .wednesday
        case "thursday":
            return .thursday
        case "friday":
            return .friday
        case "saturday":
            return .saturday
        case "sunday":
            return .sunday
        default:
            return nil
        }
    }
}
