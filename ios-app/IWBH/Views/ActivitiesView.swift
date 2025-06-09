import SwiftUI

struct Activity {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let emoji: String
    let duration: String
}

struct ActivitiesView: View {
    let activities = [
        // Communication & Connection
        Activity(title: "Daily Check-In", description: "Ask each other 'How was your day?' and really listen to the answer. Share one thing you're grateful for about each other.", category: "Communication", emoji: "💬", duration: "10 mins"),
        Activity(title: "Love Language Session", description: "Spend time expressing love in your partner's preferred love language - words, touch, gifts, acts of service, or quality time.", category: "Communication", emoji: "💕", duration: "30 mins"),
        Activity(title: "Phone-Free Dinner", description: "Eat together without any devices. Talk about your dreams, funny memories, or plan future adventures.", category: "Communication", emoji: "🍽️", duration: "45 mins"),
        
        // Fun & Playful
        Activity(title: "Dance in the Kitchen", description: "Put on your favorite songs and dance while cooking or cleaning together. Silly dancing encouraged!", category: "Fun", emoji: "💃", duration: "15 mins"),
        Activity(title: "Try Something New", description: "Learn a new skill together - cooking a cuisine you've never tried, a board game, or a YouTube tutorial.", category: "Fun", emoji: "🆕", duration: "1-2 hours"),
        Activity(title: "Memory Lane Walk", description: "Take a walk and share favorite memories from your relationship or childhood stories you haven't told yet.", category: "Fun", emoji: "🚶‍♀️", duration: "30 mins"),
        
        // Stress Relief
        Activity(title: "5-Minute Meditation", description: "Do a guided meditation together using an app. Focus on breathing and being present with each other.", category: "Stress Relief", emoji: "🧘‍♀️", duration: "5 mins"),
        Activity(title: "Shoulder Massage", description: "Take turns giving each other a 5-minute shoulder massage. No phones, just connection and relaxation.", category: "Stress Relief", emoji: "💆‍♀️", duration: "10 mins"),
        Activity(title: "Gratitude Exchange", description: "Each person shares 3 things they're grateful for about their partner and 3 things they're grateful for in general.", category: "Stress Relief", emoji: "🙏", duration: "15 mins"),
        
        // Quality Time
        Activity(title: "Sunrise/Sunset Watch", description: "Watch the sunrise or sunset together in comfortable silence or while sharing what you're looking forward to.", category: "Quality Time", emoji: "🌅", duration: "20 mins"),
        Activity(title: "Create Together", description: "Draw, paint, or craft something together. It doesn't have to be good - just have fun creating!", category: "Quality Time", emoji: "🎨", duration: "45 mins"),
        Activity(title: "Future Dreams Talk", description: "Share your hopes and dreams for the next year, 5 years, or your retirement. Plan mini steps to achieve them.", category: "Quality Time", emoji: "✨", duration: "30 mins")
    ]
    
    @State private var selectedCategory = "All"
    let categories = ["All", "Communication", "Fun", "Stress Relief", "Quality Time"]
    
    var filteredActivities: [Activity] {
        if selectedCategory == "All" {
            return activities
        } else {
            return activities.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        VStack {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Activities List
            List(filteredActivities, id: \.id) { activity in
                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                    HStack {
                        Text(activity.emoji)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.title)
                                .font(.headline)
                            
                            Text(activity.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            HStack {
                                Text(activity.category)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                Text(activity.duration)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Peace Activities")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ActivityDetailView: View {
    var activity: Activity
    @State private var isCompleted = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack {
                    Text(activity.emoji)
                        .font(.system(size: 80))
                    
                    Text(activity.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Label(activity.category, systemImage: "tag")
                        Spacer()
                        Label(activity.duration, systemImage: "clock")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to do it:")
                        .font(.headline)
                    
                    Text(activity.description)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Tips
                VStack(alignment: .leading, spacing: 10) {
                    Text("💡 Pro Tips:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Put away distractions (phones, TV)")
                        Text("• Focus on enjoying the moment together")
                        Text("• Don't worry about doing it 'perfectly'")
                        Text("• If tensions arise, take a deep breath and remember you're on the same team")
                    }
                    .font(.body)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Complete Button
                Button(action: {
                    isCompleted.toggle()
                }) {
                    HStack {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        Text(isCompleted ? "Completed! 🎉" : "Mark as Done")
                    }
                    .font(.headline)
                    .foregroundColor(isCompleted ? .white : .blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCompleted ? Color.green : Color.blue.opacity(0.1))
                    .cornerRadius(15)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}