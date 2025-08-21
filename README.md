# 🌍 EcoMiles – Smart Route Optimization App  
**Find the apk file in the current directory**
EcoMiles is a Flutter-based navigation app that helps users **choose routes based on time or environmental impact**.  
It integrates with **Google Maps APIs** for real-time routing and introduces a unique **Eco Mode** that optimizes for pollution reduction within **Gurugram** using a custom dataset.  

---

## ✨ Features  

- 🚗 **Two Route Modes**:  
  - **Time Mode** – Standard routing powered by Google Maps (works anywhere).  
  - **Eco Mode** – Pollution-optimized routing (works only within **Gurugram**).  

- 📍 **Current Location Tracking**:  
  - Uses device GPS with permissions handling.  
  - Automatically updates if user moves beyond a small threshold.  

- 🗺 **Route Visualization**:  
  - Interactive map powered by `google_maps_flutter`.  
  - Supports camera animations and polyline drawing for routes.  

- 🔄 **Loading & Error Handling**:  
  - Non-blocking loading overlay during route fetching.  
  - Snackbar notifications for invalid input or unavailable routes.  

- 🛠 **Tech Stack**:  
  - **Flutter** (Dart)  
  - **Google Maps SDK & APIs**  
  - Location services (`location` package)  
  - State management with **Provider**  
  

---

## 📖 When to Use Each Mode  

- **Time Mode** ⏱  
  - Works everywhere.  
  - Best when you want the **fastest route** regardless of pollution.  

- **Eco Mode** 🌱  
  - Works **only in Gurugram** (trained dataset).  
  - Best when you want to **minimize pollution & environmental impact**.  

⚠️ If you try to use Eco Mode outside Gurugram, the app will notify you.  

---

