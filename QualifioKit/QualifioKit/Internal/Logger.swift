import Foundation

internal let logger: QualifioLogger = {
    QualifioLogger(
        subsystem: "com.qualifio",
        category: "Qualifio",
        labelIgnoreList: ["Qualifio"]
    )
}()
