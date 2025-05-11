# Your Project Name Here (e.g., SyncNotes & Todos)

A powerful and seamless notes and todo tracking application designed for both online and offline productivity.

## Features

* **Effortless Note Management:** Create, read, update, and delete your notes with a simple and intuitive interface.
* **Efficient Todo Tracking:** Keep track of your tasks, mark them as finished, and easily clear completed items.
* **Offline-First Design:** This is a core feature! The app works flawlessly even when you have no internet connection. All your changes are saved locally using SQLite and automatically synced to the cloud when you regain connectivity. Never lose a thought or task again due to a spotty network.
* **Seamless Syncing:** Your data is automatically synchronized across devices through Firebase, ensuring your notes and todos are always up-to-date, whether you're online or offline.
* **Firebase Integration:** Utilizes Firebase for secure user authentication and cloud storage, enabling data synchronization.
* **Local Persistence:** Leverages SQLite to provide robust local storage, making the offline-first experience possible and ensuring quick data access.

## Screenshots

Here are some screenshots showcasing the application's interface and functionality:
<table width=100%>
  <tr>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/login - light.png" alt="Login Screen (Light)" width="200"/>
      <br/><sub><b>Login Screen (Light)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/login - dark.png" alt="Login Screen (Dark)" width="200"/>
      <br/><sub><b>Login Screen (Dark)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/signup - light.png" alt="Signup Screen (Light)" width="200"/>
      <br/><sub><b>Signup Screen (Light)</b></sub>
    </td>
     <td align="center" style="padding: 10px;">
      <img src="working screenshots/signup - dark.png" alt="Signup Screen (Dark)" width="200"/>
      <br/><sub><b>Signup Screen (Dark)</b></sub>
    </td>
  </tr>
  <br>
  <tr>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/notes - light.png" alt="Notes List (Light)" width="200"/>
      <br/><sub><b>Notes List (Light)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/notes - dark.png" alt="Notes List (Dark)" width="200"/>
      <br/><sub><b>Notes List (Dark)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/edit note - light.png" alt="Edit Note (Light)" width="200"/>
      <br/><sub><b>Edit Note (Light)</b></sub>
    </td>
     <td align="center" style="padding: 10px;">
      <img src="working screenshots/edit note - dark.png" alt="Edit Note (Dark)" width="200"/>
      <br/><sub><b>Edit Note (Dark)</b></sub>
    </td>
  </tr>
  <br>
   <tr>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/todos - light.png" alt="Todos List (Light)" width="200"/>
      <br/><sub><b>Todos List (Light)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/todos - dark.png" alt="Todos List (Dark)" width="200"/>
      <br/><sub><b>Todos List (Dark)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/new todo - light.png" alt="Add New Todo (Light)" width="200"/>
      <br/><sub><b>Add New Todo (Light)</b></sub>
    </td>
     <td align="center" style="padding: 10px;">
      <img src="working screenshots/new todo - dark.png" alt="Add New Todo (Dark)" width="200"/>
      <br/><sub><b>Add New Todo (Dark)</b></sub>
    </td>
  </tr>
  <br>
  <tr>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/drawer - light.png" alt="Navigation Drawer (Light)" width="200"/>
      <br/><sub><b>Navigation Drawer (Light)</b></sub>
    </td>
     <td align="center" style="padding: 10px;">
      <img src="working screenshots/choose theme - light.png" alt="Theme Selection (Light)" width="200"/>
      <br/><sub><b>Theme Selection (Light)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/confirm delete - light.png" alt="Confirm Delete (Light)" width="200"/>
      <br/><sub><b>Confirm Delete (Light)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/confirm clear - light.png" alt="Confirm Clear Completed (Light)" width="200"/>
      <br/><sub><b>Confirm Clear Completed (Light)</b></sub>
    </td>
  </tr>
  <br>
  <tr>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/drawer - dark.png" alt="Navigation Drawer (Dark)" width="200"/>
      <br/><sub><b>Navigation Drawer (Dark)</b></sub>
    </td>
     <td align="center" style="padding: 10px;">
      <img src="working screenshots/choose theme - dark.png" alt="Theme Selection (Dark)" width="200"/>
      <br/><sub><b>Theme Selection (Dark)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/confirm delete - dark.png" alt="Confirm Delete (Dark)" width="200"/>
      <br/><sub><b>Confirm Delete (Dark)</b></sub>
    </td>
    <td align="center" style="padding: 10px;">
      <img src="working screenshots/confirm clear - dark.png" alt="Confirm Clear Completed (Dark)" width="200"/>
      <br/><sub><b>Confirm Clear Completed (Dark)</b></sub>
    </td>
  </tr>
</table>

## Built With

* **Flutter:** UI Toolkit
* **Provider:** State Management
* **sqflite:** Local SQLite Database
* **Firebase Core/Auth/Firestore:** Backend Authentication and Cloud Database
* **connectivity\_plus:** Network Connectivity Checks

## Getting Started

Follow these steps to get the project up and running on your local machine.

### Prerequisites

* Flutter SDK installed.
* Dart SDK included with Flutter.
* Android Studio or VS Code with Flutter and Dart plugins.
* A Firebase project set up.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/mussie-alemayehu/notes-and-to-do.git
    cd notes-and-to-do
    ```
2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup using FlutterFire CLI:**
    * Ensure you have the Firebase CLI installed. If not, follow the instructions [here](https://firebase.google.com/docs/cli#install_the_firebase_cli).
    * Install the FlutterFire CLI by running:
        ```bash
        dart pub global activate flutterfire_cli
        ```
    * Log in to Firebase:
        ```bash
        firebase login
        ```
    * Navigate to your project directory in the terminal.
    * Configure your Flutter project to use Firebase by running:
        ```bash
        flutterfire configure
        ```
        Follow the prompts to select your Firebase project and the platforms you want to configure.
    * Ensure Firebase Authentication and Cloud Firestore are enabled in your Firebase project console.

### Running the App

Connect a device or start an emulator and run:

```bash
flutter run
```

## Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix:
    ```bash
    git checkout -b feature/your-feature-name
    ```
    or
    ```bash
    git checkout -b bugfix/your-bug-name
    ```
3.  Make your changes and commit them with clear and concise messages.
4.  Push your branch to your fork:
    ```bash
    git push origin feature/your-feature-name
    ```
5.  Create a Pull Request from your fork to the main repository. Please provide a detailed description of your changes.

<br>

By [Mussie Alemayehu](https://linkedin.com/in/mussie-alemayehu)