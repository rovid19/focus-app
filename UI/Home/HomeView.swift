//
//  ContentView.swift
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
                // Timer Section
                controller.focusView
                
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
                
            } else {
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
        .padding()
        .frame(minWidth: 300, minHeight: 400)
    }
}