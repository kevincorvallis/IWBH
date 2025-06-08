import SwiftUI

struct InterestTag: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .foregroundColor(.blue)
    }
}

struct InterestTag_Previews: PreviewProvider {
    static var previews: some View {
        InterestTag(text: "Cooking", onRemove: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}