# Publishing CardDue

App name: CardDue. Bundle ID: `com.gnx072.carddue`. iPhone only, iOS 17 or later, free.

## Checklist

Possible now:

- [ ] Test the monthly reset with Simulate Next Month (step 3)
- [ ] Take screenshots (step 8)
- [ ] Read the listing text and form answers (step 7)

Needs the approved Developer Program membership:

- [ ] Select the paid team in Xcode, not Personal Team (step 2)
- [ ] Create the app in App Store Connect (step 5)
- [ ] Upload a build (step 6)
- [ ] Enter the listing and form answers (step 7)
- [ ] Submit for review (step 9)

Already done: support page, privacy policy page, app icon, privacy manifest.

## 1. Get the code on your Mac

Install the current Xcode from the Mac App Store and open it once. Then in Terminal:

```bash
git clone https://github.com/gnx072/carddue.git
```

```bash
open carddue/CardDue.xcodeproj
```

## 2. Sign in and set your team

1. Xcode > Settings > Accounts: add the Apple ID of your Developer Program membership.
2. Click the blue CardDue project, then the CardDue target, then Signing & Capabilities.
3. Pick your team under Team. Leave "Automatically manage signing" on.

If Xcode says the bundle ID is taken, change it to something else, such as `com.yourname.carddue`.

If the project will not open, tell Claude the exact error. As a fallback, create a new iOS App project in Xcode (SwiftUI, named CardDue), replace its files with the ones in the `CardDue` folder, then use the same settings: iOS 17, iPhone only.

## 3. Test on your iPhone

1. Connect the iPhone by cable and trust the Mac.
2. On the iPhone, turn on Settings > Privacy & Security > Developer Mode, then restart it.
3. In Xcode, pick your iPhone at the top and press Run (Cmd+R).

Check these:

- Add two cards. Allow notifications when asked.
- Tick one off. It moves to Paid.
- Open Settings in the app and tap Simulate Next Month. Everything is unpaid and the title shows next month. Leave the app and reopen it: the real month and your ticks return.
- Set a reminder for a card due tomorrow and confirm that it arrives at 9:00 AM.

## 4. Publish the support and privacy pages

On GitHub, open the repository, then Settings > Pages. Under Source pick "Deploy from a branch", branch `main`, folder `/docs`, and save. After a minute or two, these work:

- Support URL: https://gnx072.github.io/carddue/
- Privacy Policy URL: https://gnx072.github.io/carddue/privacy.html

## 5. Create the app in App Store Connect

At https://appstoreconnect.apple.com go to Apps, press +, then New App:

- Platform: iOS
- Name: CardDue. If it is taken, try "CardDue: Payment Checklist".
- Primary language: English
- Bundle ID: `com.gnx072.carddue`. If it isn't listed, register it at developer.apple.com under Identifiers, or let Xcode register it by doing step 2 first.
- SKU: `carddue`

## 6. Upload a build

1. In Xcode, set the run destination to Any iOS Device (arm64).
2. Product > Archive.
3. When the Organizer opens, press Distribute App, then App Store Connect, then Upload.
4. Wait for the build to finish processing in App Store Connect. Apple sends an email.
5. Optional but useful: install it through TestFlight on your iPhone.

If it asks about encryption, answer that the app uses none.

For every later upload, increase Build in the target's General tab.

## 7. Fill in the listing

Suggested text:

- Subtitle: Credit card due date checklist
- Promotional text: Never miss a card payment. Check it off, and it resets on the 1st.
- Keywords: credit card,due date,bill,reminder,payment,checklist,tracker
- Description:

> CardDue is the simplest way to remember your credit card payments.
>
> Add each card with its due day. When you pay, check it off. On the 1st of every month, all cards return to unpaid, so your list is ready for the new month.
>
> - See what is still to pay, sorted by due date
> - Get a reminder before each due date
> - Choose when you are reminded
> - No amounts, accounts or card numbers
> - No sign-in, ads or tracking. Your data stays on your iPhone.

Other fields:

- Category: Finance
- Price: Free. Choose this under Pricing and Availability.
- Age rating: answer the questionnaire. Every answer should be No or None, because the app has no such content, no web access and no user-generated content shared with others.
- App Privacy: choose "Data Not Collected" and publish it. The app has no tracking, accounts or analytics.
- Encryption: the app uses none.
- Content rights: the app contains no third-party content.
- App Review contact: your name, phone number and email. Apple keeps these private.
- Sign-in required: No.
- Privacy Policy URL and Support URL: from step 4.
- Copyright: 2026, and your name.
- EU: App Store Connect asks whether you are a trader under the Digital Services Act. A trader's contact details are shown publicly in the EU. If you would rather not do that, remove the EU countries from Availability.

## 8. Take screenshots

Apple requires screenshots for its largest iPhone size.

1. In Xcode, pick the largest iPhone Pro Max simulator and press Run.
2. Add a few sample cards with generic names, such as Travel Card, Store Card and Car Loan. Avoid bank and card brand names, which can cause a rejection. Mark one as paid.
3. Press Cmd+S in the Simulator to save a screenshot. Don't use a Mac screenshot, which includes the phone frame and is the wrong size. Take the list and Add Card. Skip Settings, because test builds show the Simulate Next Month button there.
4. Upload them on the version page in App Store Connect.

## 9. Submit for review

1. On the version page, choose your build under Build.
2. In Review Notes, write: "No login required. Tap + to add a card, tick the circle to mark it as paid. The app stores everything on the device."
3. Press Add for Review, then Submit to App Review.

Review usually takes a day or two. If Apple rejects the app, paste the message to Claude and we will fix it.
