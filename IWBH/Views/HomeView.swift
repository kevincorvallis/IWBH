import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var trackersModel: CustomTrackersModel
    @EnvironmentObject private var connectionModel: PartnerConnectionModel
    @EnvironmentObject private var authModel: AuthenticationModel

    var primaryTracker: CustomTracker? {
        trackersModel.trackers.first { $0.isPrimary } ?? trackersModel.trackers.first
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    if let tracker = primaryTracker {
                        primaryTrackerCard(tracker)
                    } else {
                        emptyTrackerCard
                    }

                    quickActionsSection

                    if !trackersModel.trackers.isEmpty {
                        recentActivitySection
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            trackersModel.loadTrackers()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        let displayInitial = connectionModel.userProfile?.displayName.prefix(1) ?? "?"

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Good \(getGreeting())!")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if authModel.isGuest {
                        Text("You’re using guest mode")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } else if connectionModel.pairingStatus == .paired,
                              let partnerInfo = connectionModel.userProfile?.partnerProfile {
                        Text("You and \(partnerInfo.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Welcome back")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(displayInitial)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Primary Tracker Card
    private func primaryTrackerCard(_ tracker: CustomTracker) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(tracker.emoji)
                    .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tracker.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Primary Tracker")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(trackersModel.getCurrentValue(for: tracker))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(tracker.color))

                    Text(tracker.unit)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(tracker.color).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(tracker.color).opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    // MARK: - Empty Tracker Card
    private var emptyTrackerCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No Trackers Yet")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Create your first relationship tracker to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            NavigationLink(destination: TrackersView()) {
                Text("Create Tracker")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(.blue))
                    .cornerRadius(10)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: TrackersView()) {
                    QuickActionCard(
                        icon: "plus.circle.fill",
                        title: "New Tracker",
                        subtitle: "Create custom tracker",
                        color: .blue
                    )
                }

                NavigationLink(destination: ActivitiesView()) {
                    QuickActionCard(
                        icon: "heart.fill",
                        title: "Activities",
                        subtitle: "Find things to do",
                        color: .pink
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()

                NavigationLink(destination: TrackersView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            LazyVStack(spacing: 8) {
                ForEach(Array(trackersModel.trackers.prefix(3)), id: \.id) { tracker in
                    NavigationLink(destination: TrackerDetailView(tracker: tracker, trackersModel: trackersModel)) {
                        RecentActivityRow(tracker: tracker, model: trackersModel)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helper: Greeting
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "night"
        }
    }
}
