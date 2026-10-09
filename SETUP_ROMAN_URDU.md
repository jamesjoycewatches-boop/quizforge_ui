# QuizForge UI — Roman Urdu Setup Guide

## Yeh project kya hai?

Yeh ek reusable Flutter multiple-choice quiz package hai. Is mein question cards, progress, answer feedback, explanations, results aur restart feature hain. Kisi private taxi app ka source code, questions, logo ya customer data is project mein shamil nahi.

## Step 1: ZIP extract karo

ZIP ko apne computer par extract karo. `quizforge_ui` folder ko VS Code ya Android Studio mein kholo.

## Step 2: Flutter SDK install / verify karo

Terminal mein:

```bash
flutter doctor
flutter pub get
flutter analyze lib test
flutter test
```

Agar Flutter install nahi, to Flutter ki official website `https://docs.flutter.dev/get-started/install` follow karo.

## Step 3: Demo run karo

```bash
cd example
flutter create --platforms=android,ios,web .
flutter pub get
flutter run -d chrome
```

## Step 4: GitHub par upload (public karne se pehle review zaroor)

1. GitHub par `quizforge_ui` naam se naya repository create karo.
2. Private ya public visibility khud select karo. Open-source project ke liye akhir mein public hona chahiye.
3. README aur `pubspec.yaml` mein `YOUR_USERNAME` ko apne asli GitHub username se replace karo.
4. Project folder ke andar terminal mein:

```bash
git init
git add .
git commit -m "Initial QuizForge UI preview"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/quizforge_ui.git
git push -u origin main
```

5. GitHub Actions checks green hone ka wait karo. Issues aur private security reporting enable karo.
6. Genuine usage, documentation updates, bug reports, contributions aur releases par kaam karte raho.

## ChatGPT Pro application ke baare mein important baat

Yeh project **sirf starter** hai. OpenAI ka Codex for Open Source program impactful, actively maintained public OSS projects ko assess karta hai. Sirf public repo create karne se 6 months free Pro milna guaranteed nahi. Application mein kabhi users, stars, commits, contributions ya impact ke fake claims mat karna.

Official form: https://openai.com/form/codex-for-oss/
