import Foundation

/// Topics are hardcoded, not fetched from a server — First Aid content ships
/// inside the app bundle so it works fully offline.
final class StaticFirstAidTopicRepository: FirstAidTopicRepositoryProtocol {
    func fetchAll() -> [FirstAidTopic] {
        [
            FirstAidTopic(
                id: "cpr-adult",
                title: "Adult CPR",
                summary: "Chest compressions and rescue breaths for an unresponsive adult.",
                systemImage: "heart.fill",
                videoResourceName: "cpr_adult"
            ),
            FirstAidTopic(
                id: "cpr-infant",
                title: "Infant CPR",
                summary: "Modified CPR technique for infants under 12 months.",
                systemImage: "figure.child",
                videoResourceName: "cpr_infant"
            ),
            FirstAidTopic(
                id: "choking",
                title: "Choking (Heimlich Maneuver)",
                summary: "Abdominal thrusts to clear an obstructed airway.",
                systemImage: "lungs.fill",
                videoResourceName: "choking"
            ),
            FirstAidTopic(
                id: "bleeding",
                title: "Severe Bleeding",
                summary: "Applying pressure and controlling blood loss until help arrives.",
                systemImage: "bandage.fill",
                videoResourceName: "bleeding"
            ),
            FirstAidTopic(
                id: "burns",
                title: "Burns",
                summary: "Cooling and covering a burn safely.",
                systemImage: "flame.fill",
                videoResourceName: "burns"
            )
        ]
    }
}
