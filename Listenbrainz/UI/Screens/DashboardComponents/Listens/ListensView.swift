//
//  ContentView.swift
//  Listenbrainz
//
//  Created by Akshat Tiwari on 19/03/23.
//

import SwiftUI

struct ListensView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var insetsHolder: InsetsHolder
    @StateObject var dashboardViewModel = DashboardViewModel(repository: DashboardRepositoryImpl())
    @State private var selectedTab = 0
    @State private var isSettingsPressed = false
    @State private var isSearchActive = false
    @State private var showPinTrackView = false
    @State private var showingRecommendToUsersPersonallyView = false
    @State private var showWriteReview = false
    @State private var selectedListen: Listen?
    @State private var isPresented: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(Strings.AppStorageKeys.userName) private var userName: String = ""
    @AppStorage(Strings.AppStorageKeys.userToken) private var userToken: String = ""

    var body: some View {
        ZStack {
            colorScheme == .dark ? Color.backgroundColor : Color.white
            VStack {
                TopBar(isSettingsPressed: $isSettingsPressed, isSearchActive: $isSearchActive, customText: topBarTitle)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        TabButton(title: "Listens", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Stats", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "Taste", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                        TabButton(title: "Playlists", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                        TabButton(title: "Created for you", isSelected: selectedTab == 4) {
                            selectedTab = 4
                        }
                    }
                    .padding()
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                if selectedTab == 0 {
                    ScrollView {
                        VStack {
                            ListensStatsView()
                                .environmentObject(dashboardViewModel)

                            SongDetailView(
                                onPinTrack: { listen in
                                    selectedListen = listen
                                    showPinTrackView = true
                                },
                                onRecommendPersonally: { listen in
                                    selectedListen = listen
                                    showingRecommendToUsersPersonallyView = true
                                },
                                onWriteReview: { listen in
                                    selectedListen = listen
                                    showWriteReview = true
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? Color(.systemBackground).opacity(0.1) : Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            
                            Spacer(minLength: 8)
                        }
                    }.padding(.bottom, insetsHolder.tabBarHeight)
                } else if selectedTab == 1 {
                    StatisticsView()
                        .environmentObject(dashboardViewModel)
                } else if selectedTab == 2 {
                    TasteView()
                        .environmentObject(dashboardViewModel)
                } else if selectedTab == 3 {
                    PlaylistView()
                        .environmentObject(dashboardViewModel)
                } else {
                    CreatedForYouView()
                        .environmentObject(dashboardViewModel)
                }
            }
            .sheet(isPresented: $isSettingsPressed) {
                SettingsView()
            }
            .centeredModal(isPresented: $showPinTrackView) {
                if let listen = selectedListen {
                    PinTrackView(
                        isPresented: $showPinTrackView,
                        item: listen,
                        userToken: userToken,
                        dismissAction: {
                            showPinTrackView = false
                        }
                    )
                    .environmentObject(homeViewModel)
                }
            }
            .centeredModal(isPresented: $showingRecommendToUsersPersonallyView) {
                if let listen = selectedListen {
                    RecommendToUsersPersonallyView(item: listen, userName: userName, userToken: userToken, dismissAction: {
                        showingRecommendToUsersPersonallyView = false
                    })
                    .environmentObject(homeViewModel)
                }
            }
            .centeredModal(isPresented: $showWriteReview) {
                if let listen = selectedListen {
                    WriteAReviewView(isPresented: $showWriteReview, item: listen, userToken: userToken, userName: userName) {
                        showWriteReview = false
                    }
                    .environmentObject(homeViewModel)
                }
            }
        }
        .onAppear {
            homeViewModel.requestMusicData(userName: userName)
            dashboardViewModel.userName = userName
            dashboardViewModel.getListenCount(username: userName)
            dashboardViewModel.getFollowers(username: userName)
            dashboardViewModel.getFollowing(username: userName)
        }
    }

    private var topBarTitle: String {
        switch selectedTab {
        case 0:
            return "Listens"
        case 1:
            return "Statistics"
        case 2:
            return "Taste"
        case 3:
            return "Playlists"
        case 4:
            return "Created for You"
        default:
            return "Listens"
        }
    }
}




struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Rectangle().fill(Color.secondary) : Rectangle().fill(Color.black.opacity(0.2)))
                .foregroundColor(.white)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .frame(maxWidth: .infinity)
    }
}




