import WidgetKit
import SwiftUI

struct LyricsWidget: Widget {
    let kind: String = "LyricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LyricsTimelineProvider()) { entry in
            LyricsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lyrico Widget")
        .description("Displays manual-scrolling synced song lyrics.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
