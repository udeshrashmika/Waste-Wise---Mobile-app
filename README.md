♻️ Waste-Wise: AI-Powered Waste Management System

**Waste-Wise** is a modern Flutter-based mobile application designed to revolutionize urban waste collection. By integrating **AI Image Recognition (TensorFlow Lite)** and **Real-time Firebase Analytics**, the app connects residents, drivers, and administrators to build a cleaner, smarter environment.

🚀 Key Features

##🏠 Resident Module
* **AI Bin Level Detection:** Upload photos of waste bins to automatically detect levels (Empty, Half, Full) using a trained **TFLite model**.
* **Waste Categorization:** Categorize disposals as **Organic, Plastic, or Glass** to assist in efficient recycling.
* **Real-time Alerts:** Receive instant notifications when a collection truck is nearby or schedules change.

### 🚛 Truck Driver Module
* **Live Navigation:** Integrated **OpenStreetMap** for real-time truck tracking and optimized stop management.
* **QR Confirmation:** Scan bin-specific QR codes to confirm collection and reset bin status in the database.
* **Driver Profile & History:** Track collection performance and view upcoming schedules.

### 📊 Admin Dashboard
* **Waste Analytics:** Visualized real-time charts showing the distribution of waste types (Organic/Plastic/Glass) across the complex.
* **User Management:** Oversee Resident and Driver accounts with specialized role-based access.
* **Dynamic Scheduling:** Create and update waste collection calendars for different zones.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Cloud Firestore, Authentication, Storage)
* **AI/ML:** TensorFlow Lite (Custom Image Classification Model)
* **Maps:** OpenStreetMap 

---

## 👥 Project Team & Contributions

This project was developed by a team of 10 members. Below is the contribution breakdown based on official Git history:

| Contributor | GitHub ID |
| :--- | :--- | :--- |
| **Udesh Rashmika** | `Udesh` |  
| **Yasiru Induwara** | `Yasiru-I` | 
| **Ambalangoda Silva** | `Tharana10` | 
| **Omira Athukorala** | `omiraDev` | 
| **Migel Cristeen** | `Irosh Cristeen` |
| **Balasuriya Chathushi** | `chathu005` |
| **Dona Karunathilaka** | `Isuruni` | 
| **Wijesooriya Wijesooriya**| `rashmiwi` |
| **Uditha Thilakawardana** | `Sankalpa-io` | 
| **Poojani Karunapala** | `Onelle-creator ` | 

---

⚙️ Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/udeshrashmika/Waste-Wise---Mobile-app.git](https://github.com/udeshrashmika/Waste-Wise---Mobile-app.git)
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration:**
    * Add your `google-services.json` to `android/app/`.
    * Enable Firestore, Authentication (Email/Password), and Storage in the Firebase Console.

4.  **Run the Application:**
    ```bash
    flutter run
    ```
---
**© 2026 Waste-Wise Team | Towards a Greener Sri Lanka.**
