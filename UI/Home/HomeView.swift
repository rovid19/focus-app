//
//  HomeView.swift
//  focus-app
//
//  Created by Roberto Vidovic on 10.08.2025..
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var controller: HomeController
    @EnvironmentObject var supabaseAuth: SupabaseAuth

    var body: some View {
        VStack(spacing: 20) {
            if supabaseAuth.user != nil {
                // Top Menu Bar
                HStack(spacing: 0) {
                    Button(action: {
                        controller.switchView(to: "focus")
                    }) {
                        Text("Focus")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(controller.whichView == "focus" ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(controller.whichView == "focus" ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        controller.switchView(to: "stats")
                    }) {
                        Text("Statistics")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(controller.whichView == "stats" ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(controller.whichView == "stats" ? Color.blue : .clear)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 15)
                }
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            }
            Group {
                // Timer Section
                if supabaseAuth.user != nil {
                    if controller.whichView == "focus" {
                        controller.focusView
                    } else if controller.whichView == "stats" {
                        controller.statsView
                    }
                }
            }
            if supabaseAuth.user != nil {
                // Action Buttons
                HStack(spacing: 15) {
                    Button("Settings") {
                        // Settings action
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Logout") {
                        controller.logout()
                        print("Logged out")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }

                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            } else {
                // login page
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Welcome to Focus App")
                        .font(.title2)
                        .fontWeight(.medium)

                    Button("Sign in with Google") {
                        controller.signIn()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
