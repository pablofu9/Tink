//
//  MessageView.swift
//  Tink
//
//  Created by Pablo Fuertes ruiz on 24/2/25.
//

import SwiftUI

struct MessageView: View {
    
    let message: Message
    @State var showTime: Bool = true
    var isReceivedMessage: Bool {
        UserDefaults.standard.userSaved?.id != message.users
    }
    
    var body: some View {
        VStack(alignment: isReceivedMessage ? .leading : .trailing) {
            HStack {
                Text(message.text)
                    .padding()
                    .foregroundStyle(isReceivedMessage ? ColorManager.defaultWhite : ColorManager.primaryGrayColor)
                    .font(.custom(CustomFonts.regular, size: 16))
                    .background(isReceivedMessage ? ColorManager.primaryBasicColor : ColorManager.secondaryGrayColor)
                    .multilineTextAlignment(.leading)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity, alignment: isReceivedMessage ? .leading : .trailing)
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .foregroundStyle(ColorManager.primaryGrayColor.opacity(0.7))
                    .font(.custom(CustomFonts.regular, size: 15))
                    .padding(isReceivedMessage ? .leading : .trailing)
                
            }
        }
        .frame(maxWidth: .infinity,  alignment: isReceivedMessage ? .leading : .trailing)
        .padding(isReceivedMessage ? .leading : .trailing)
        .padding(.horizontal, 10)
        
    }
}

#Preview {
    MessageView(message: Message(id: "1", text: "Primer mensaje", received: true, timestamp: Date(), users: "1"))
}
