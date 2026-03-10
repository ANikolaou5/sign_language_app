# Project Title

Promoting sign language learning through a gamified multiplatform mobile experience

**Author:** Antri Nikolaou  
**Contact:** ANikolaou5@uclan.ac.uk  
**Repository:** https://github.com/ANikolaou5/sign_language_app

---

## Table of Contents
<details>
  <summary><strong>Expand</strong></summary>

- [About the Project](#about-the-project)
  - [Key Features](#key-features)
  - [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Usage](#usage)
- [Development](#development)
  - [Running Tests](#running-tests)
  - [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

</details>

---

## About the Project

Hearing-impaired people frequently deal with barriers when communicating with other people that do not know sign language or when learning sign language, often due to lack of access to structured and economical learning means. So this project aims to solve this by designing and developing a mobile application for learning sign language using gamified, interactive activities and various features. This app is called SiLAc (Sign Language Accessibility) and it shapes sign language learning into a productive and enjoyable practice, despite the person’s background or prior experience.

### Key Features

- ASL Signs & Gestures Learning
- 1-1 Competing
- Leaderboard & Achievement Badges

### Technology Stack

- Dart
- Flutter
- Firebase Realtime Database & Local Storage
- Gradle

---

## Getting Started

Instructions for setting up the project locally.

### Prerequisites

```sh
flutter --version # is 3.38.9
dart --version # is 3.10.8
```

### Installation

```sh
git clone https://github.com/ANikolaou5/sign_language_app.git
cd sign_language_app
flutter pub get
```

### Configuration

Place google-services.json in android/app

---

## Usage

```sh
flutter run
```

---

## Development

### Running Tests

```sh
flutter test
```

### Project Structure

```text
assets/
lib/
├── classes/
├── components/
├── screens/
├── services/
└── firebase_options.dart
└── main.dart
test/
└── unit_test.dart
└── widget_test.dart
```

---

## Roadmap

- [x] UI Navigation and Firebase integration.
- [x] Gamified activities.
- [x] Multiplayer mode implementation.
- [ ] Learning through video tutorials.
- [ ] Gesture recognition using the device camera.

---

## Contributing

Contribution guidelines and workflow expectations.

---

## License

License name and link to the LICENSE file.

---

## Contact

Antri Nikolaou  
ANikolaou5@uclan.ac.uk  
https://github.com/ANikolaou5  

---

## Acknowledgments

Credits, references, and inspirations.
