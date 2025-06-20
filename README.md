# Wlog Mobile App

A dark-mode Flutter mobile application for marketing teams to upload, manage, analyze, and collaborate on video content. Originally built for a Sofindex client, this is the fully re-implemented version as a personal project.

---

## 📖 Table of Contents

1. [About the Project](#about-the-project)  
2. [Features](#features)  
3. [Media](#media)  
4. [Tech Stack](#tech-stack)  
---

## 📝 About the Project

Wlog is a Flutter-based mobile app designed to streamline video content workflows for marketing teams. It features:

- A customizable dark-mode UI with vibrant gradient accents  
- End-to-end flows: authentication, uploads, analytics dashboard, team chat, and user profile  
- Export-ready Figma design hand-off conventions

---

## ✨ Features

- **Authentication**  
  - Splash screen with animated gradient logo  
  - Login & Sign-Up forms with error handling  

- **Home / Analytics Dashboard**  
  - Video cards list with thumbnails, titles, view counts  
  - "Best Performers" highlight card with gradient glow  
  - Summary cards for total videos, views, engagement rate  

- **Upload Flow**  
  - Remote vs. Local storage tabs  
  - File picker with progress bar and live percentage  
  - FAB for creating new blog/video entries  

- **Team Collaboration**  
  - Real-time chat with avatars and status indicators  
  - Threaded messaging UI and send actions  

- **Profile & Settings**  
  - User info header, navigation to "My Videos," "Analytics," "Team," and "Settings"  
  - Log Out action with confirmation  

---

## 📸 Media

### Logos
![Logo 1](assets/media/1.png)   ![Logo 2](assets/media/2.png)  

### Splash Screen
 ![Logo SVG](assets/media/1.svg)


### Dashboard
  ![Dashboard SVG](assets/media/dashboard.svg)

### Upload Flow
 ![Upload SVG](assets/media/upload.svg)

### Analytics
![Analytics SVG](assets/media/analytics.svg)


### Profile
![Profile SVG](assets/media/profile.svg)

---

## 🛠️ Tech Stack

- **Frontend**: Flutter, Dart
- **State Management**: Flutter Bloc
- **Backend**: Supabase
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Dependencies**:
  - flutter_bloc: State management
  - supabase_flutter: Backend integration
  - fpdart: Functional programming
  - image_picker: Media selection
  - dotted_border: UI elements
  - get_it: Dependency injection
  - uuid: Unique identifiers
