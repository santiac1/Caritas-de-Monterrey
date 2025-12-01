import SwiftUI

struct CampaignDetailView: View {
    let campaign: Campaign
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Image
                if let imageUrl = campaign.image_url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 250)
                                .overlay(ProgressView())
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 250)
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
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "megaphone.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.secondaryBlue)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(campaign.title)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.primary)
                    
                    // Date
                    HStack {
                        Image(systemName: "calendar")
                        Text(campaign.formattedDateRange)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    // Description
                    Text(campaign.description)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}
