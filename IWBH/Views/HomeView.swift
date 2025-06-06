import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var trackersModel: CustomTrackersModel
    @EnvironmentObject private var connectionModel: PartnerConnectionModel
    
    var primaryTracker: CustomTracker? {
        trackersModel.trackers.first { $0.isPrimary } ?? trackersModel.trackers.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                mainContent
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            trackersModel.loadTrackers()
        }
    }
    
    private var mainContent: some View {
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
    
    private var headerSection: some View {
        let displayInitial = connectionModel.userProfile?.displayName.prefix(1) ?? "?"
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Good \(getGreeting())!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if connectionModel.pairingStatus == .paired,
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

    
    private func primaryTrackerButtons(_ tracker: CustomTracker) -> some View {
        VStack(spacing: 12) {
            if tracker.trackingType == .negativeEvent {
                Button(action: {
                    trackersModel.recordNegativeEvent(for: tracker)
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Record Event")
                    }
                    .buttonStyleForNegativeEvent()
                }

                Button(action: {
                    trackersModel.resetTracker(tracker)
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset")
                    }
                    .buttonStyleForReset(Color(tracker.color))
                }
            } else {
                Button(action: {
                    trackersModel.incrementTracker(tracker)
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text(getIncrementText(for: tracker.trackingType))
                    }
                    .buttonStyleForIncrement(Color(tracker.color))
                }

                if tracker.trackingType == .streak {
                    Button(action: {
                        trackersModel.resetTracker(tracker)
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset")
                        }
                        .buttonStyleForReset(Color(tracker.color))
                    }
                }
            }
        }
    }
    
    private func primaryTrackerCard(_ tracker: CustomTracker) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(tracker.emoji)
                    .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tracker.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)

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

                primaryTrackerButtons(tracker)
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
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "night"
        }
    }
    
    private func getIncrementText(for type: TrackingType) -> String {
        switch type {
        case .streak: return "+1 Day"
        case .counter: return "+1"
        case .timer: return "Start"
        case .negativeEvent: return "Record Event"
        }
    }
}

// Reusable button styles to reduce code repetition
private extension View {
    func buttonStyleForNegativeEvent() -> some View {
        self.font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.red)
            .cornerRadius(8)
    }
    
    func buttonStyleForReset(_ color: Color) -> some View {
        self.font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color(color))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(color).opacity(0.1))
            .cornerRadius(8)
    }
    
    func buttonStyleForIncrement(_ color: Color) -> some View {
        self.font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(color))
            .cornerRadius(8)
    }
}
