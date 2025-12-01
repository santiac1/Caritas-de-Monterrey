import SwiftUI

struct CampaignCardHome: View {
    let campaign: Campaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            if let imageUrl = campaign.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 280, height: 160)
                            .clipped()
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 280, height: 160)
                            .overlay(ProgressView())
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 280, height: 160)
                            .overlay(
                                Image(systemName: "photo.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.secondaryBlue.opacity(0.3))
                    .frame(width: 280, height: 160)
                    .overlay(
                        Image(systemName: "megaphone.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.secondaryBlue)
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(campaign.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Text(campaign.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(campaign.formattedDateRange)
                        .font(.caption2)
                }
                .foregroundStyle(.tertiary)
            }
            .padding(12)
            .frame(width: 280, alignment: .leading)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
