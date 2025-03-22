//
//  ActivityReportView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-12-30.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct ActivityReportView: View {
    @Binding var tabSelection: Int

    let center = AuthorizationCenter.shared

    
    @StateObject var viewModel: ActivityReportViewModel = ActivityReportViewModel()
    @EnvironmentObject var screenTime: ScreenTimeService
    @State private var context: DeviceActivityReport.Context = .init(rawValue: "pie Chart")
    @State private var context2: DeviceActivityReport.Context = .init(rawValue: "Total Activity")
    
    @State private var monCount: Int = 0
    @State private var tueCount: Int = 0
    @State private var wedCount: Int = 0
    @State private var thuCount: Int = 0
    @State private var friCount: Int = 0
    @State private var satCount: Int = 0
    @State private var sunCount: Int = 0
    
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(of: .day, for: .now)!
        ),
        users: .all,
        devices: .init([.iPhone, .iPad])
    )

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    HStack {
                        Spacer()
                        Text("...")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.top, 12)
                    }
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("TOTAL")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            Text("SCREEN TIME")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                        }
                        
                        
                        Spacer()
                        Text(viewModel.currentMonth)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20))
                            
                    }
                    .padding(.horizontal, 30)
                    
                    
                    
                    Group {
                        DeviceActivityReport(.init(rawValue: "Total Activity"), filter: filter)
                            .frame(height: 100)
                    }
                    
                    HStack {
                        Image("Fishes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 145)
                            .padding(.bottom, 25)
                            .padding(.top, 10)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        
                        Text("BOUNDARIES")
                            .padding(.horizontal, 18)
                        
                        
                        DeviceActivityReport(.init(rawValue: "pill Bar"), filter: filter)
                            .frame(height: 500) // NEED TO MAKE THIS DYNAMIC
                        
                        
                        Text("BOUNDARY EXTENSIONS")
                            .padding(.horizontal, 18)
                            .padding(.top, 10)
                            .font(.system(size: 10))
                            
                    }
                    
                        
                        HStack(spacing: 1) {
                            
                            extensionCountView(color: "0x1E2368", day: "MON", count: monCount)
                            extensionCountView(color: "0x454380", day: "TUE", count: tueCount)
                            extensionCountView(color: "0x7D4077", day: "WED", count: wedCount)
                            extensionCountView(color: "0x9D3B6A", day: "THU", count: thuCount)
                            extensionCountView(color: "0xDB6552", day: "FRI", count: friCount)
                            extensionCountView(color: "0xE56829", day: "SAT", count: satCount)
                            extensionCountView(color: "0xC95102", day: "SUN", count: sunCount)
                        }
                        .padding(.bottom, 30)
                    
                    VStack(alignment: .leading) {
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.black)
                            .padding(.bottom, 20)
                        
                        Text("ANALYTICS")
                            .padding(.bottom, 20)
                        
                        Divider()
                        .frame(height: 1)
                        .background(Color.black)
                        .padding(.bottom, 20)
                        
                        Text("EXTEND BOUNDARIES")
                            .padding(.bottom, 30)
                        
                    }
                    .padding(.horizontal, 18)
                   
                        
                        NavigationLink(destination: BoundaryExtensionRequestView()) {
                            Text("request boundary extension")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 30)
                    
                        Button(action: {
                                screenTime.clearAllRestrictions()
                            }) {
                                Text("override all boundaries")
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        .padding(.bottom, 50)
                    
                    
                }
                .padding(.horizontal, 18)
            }
            .onAppear {
                Task {
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to request authorization: \(error)")
                    }
                }
            }
            
        }
    }
    

    
    private func extensionCountView(color: String, day: String, count: Int) -> some View {
       
        ZStack {
            
            Rectangle()
                .frame(width: 45, height: 60)
                .foregroundColor(Color(hex: color)) // Change color
                .cornerRadius(10) // Optional rounded corners
            
            VStack {
                
                Text(String(count))
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                Text(day)
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
        
    }
}
