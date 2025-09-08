//
//  SplashView.swift
//  StudyMate
//
//  Created by Happiness Adeboye on 4/9/2025.
//



//Splash view when you're new to the app
import SwiftUI

struct SplashView: View {
    @StateObject private var userDefaults = UserDefaultsManager.shared
    @State private var userName: String = ""
    @State private var isAnimating = false
    @State private var showMainApp = false
    @State private var showWelcome = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background shapes
            VStack {
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .offset(x: isAnimating ? 50 : -50, y: isAnimating ? -30 : 30)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 150, height: 150)
                        .offset(x: isAnimating ? -30 : 30, y: isAnimating ? 40 : -40)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isAnimating)
                }
                .padding(.top, 100)
                
                Spacer()
                
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .offset(x: isAnimating ? -40 : 40, y: isAnimating ? 20 : -20)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 120, height: 120)
                        .offset(x: isAnimating ? 20 : -20, y: isAnimating ? -30 : 30)
                        .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isAnimating)
                }
                .padding(.bottom, 100)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    VStack(spacing: 12) {
                        Text("StudyMate")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                        Text("Your Personal Study Companion")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                
                // App Description
                VStack(spacing: 16) {
                    FeatureRow(icon: "calendar.badge.clock", text: "Track assignments, exams & readings")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Stay organized with priority levels")
                    FeatureRow(icon: "paintbrush.fill", text: "Color-coded by subject")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Mark tasks as complete")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Name Input Section
                VStack(spacing: 20) {
                    Text("What should we call you?")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 18))
                        
                        TextField("Enter your name", text: $userName)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .placeholder(when: userName.isEmpty) {
                                Text("Enter your name")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(.body, design: .rounded))
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 40)
                    
                    // Get Started Button
                    Button(action: {
                        // Save the user name
                        userDefaults.saveUserName(userName)
                        
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showWelcome = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showMainApp = true
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text("Get Started")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                    }
                    .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                }
                .padding(.bottom, 60)
            }
            
            // Welcome Overlay
            if showWelcome {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .scaleEffect(showWelcome ? 1.0 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showWelcome)
                        
                        Text("Welcome, \(userName)!")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(showWelcome ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.8).delay(0.3), value: showWelcome)
                        
                        Text("Let's start organizing your studies!")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .opacity(showWelcome ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.8).delay(0.6), value: showWelcome)
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
            // If user has already completed onboarding, go directly to main app
            if userDefaults.hasCompletedOnboarding && !userDefaults.userName.isEmpty {
                userName = userDefaults.userName
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showMainApp = true
                }
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            TaskListView(userName: userName.isEmpty ? userDefaults.userName : userName)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    SplashView()
}
