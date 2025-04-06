## 💡Inspiration
Outdoor exploration can be **healing**, **empowering**, and **community-building**, but it’s often **expensive** or **inaccessible**, especially for people who don’t own the right gear. We wanted to solve that.

**Arc'Tag** was inspired by the idea of making outdoor gear more **shareable**, **local**, and **sustainable**. By using **NFC tags** and a simple mobile app, we set out to build a tool that helps people lend and borrow outdoor gear in their communities, without needing lockers, shipping, or complex systems. **Just a tap**.

## 🤖What it does

Arc'Tag is a mobile app that uses NFC tags to power **peer-to-peer gear sharing**.
Here's how it works:
- Donate gear to the **shared pool** (like a backpack, jacket, or sleeping bag).
- Attach an **NFC tag** (about $0.30) to the gear and scan it into the app.
- The gear becomes available on the **map**, **gear list**, and your profile for others to reserve and borrow.
- After **connecting** with the current owner, borrowers scan the NFC tag to check out the gear. The item is now listed under your profile--**at your location**!
- When you're finished, scan again to **return** the gear.
- Users **earn points** for lending or borrowing gear.
- The more points you earn, the higher you climb on your local **leaderboard!**

## 🛠️How we built it

We built Arc'Tag using:
- **SwiftUI** for our iOS app interface
- **MapKit** for showing available gear on a community map
- **Supabase** for storing user and gear data + authentication
- **Core NFC** for scanning and writing to tags
- **Figma** to plan and design the UX/UI

## 🥊Challenges we ran into

- Managing connections and optimizing queries was tough.
- Translating our designs into actual screens was a challenge. With so many views to implement, the transition from Figma to code wasn’t as smooth as we’d hoped.

## ✅ Accomplishments that we're proud of

- Built a working prototype that reads/writes real NFC tags 
- Created a clean UX/UI flow from that accommodates all users needs 
- Designed a full point system and leaderboard experience 
- Made something low-cost and scalable for real-world community use 

## 🌱What we learned

Arc'Tag taught us so much over these past **24 hours**. NFC tags were completely new to us, and we were excited to explore both their incredible capabilities and their limitations. We discovered that tech is most exciting when it feels invisible—there’s something magical about tapping a tag and instantly checking gear in or out.

We also learned how complex **Swift integrations** can be, and that the best approach is to **start simple** and **build up**. Finally, we gained hands-on experience with **database integration**, which felt tricky at first but became much more manageable once we got the hang of it.

## 🔮What's next for Arc'Tag

- Borrowing **reminders** and gear return nudges 
- **Reviews** and **comments** for shared items 
- Manager dashboard for outdoor **organizations** to track inventory or make straight from the warehouse **donations** to the pool
- Android version so more communities can join in 
- Leaderboard/**point challenges** and team **events** 
