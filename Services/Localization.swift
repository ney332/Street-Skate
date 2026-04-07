import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(_ arguments: CVarArg...) -> String {
        String(
            format: NSLocalizedString(self, comment: ""),
            locale: Locale.current,
            arguments: arguments
        )
    }
}
