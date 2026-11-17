<div align="center">

  <!-- App Icon -->
  <img src="LearningJapp/Assets.xcassets/Dark.imageset/Dark.png" alt="Learning App Icon" width="120" height="120" />

  <h1> Learning Journey </h1>

  <p>
    <strong>A focused daily habit and learning tracker built to help you stay consistent without burnout.</strong><br />
    Set a learning goal across a week, month, or year, build your daily streak, and use smart freezes to protect your progress when life gets busy.
  </p>

  <!-- Clean, Minimalist Text Pills instead of old badges -->
  <p>
    <code><img src="https://api.iconify.design/lucide/flame.svg?color=%23F58220" width="16" height="16" align="absmiddle" /></code> •
   <code><img src="https://api.iconify.design/lucide/snowflake.svg?color=%230A8494" width="16" height="16" align="absmiddle" /></code> •
    <code><img src="https://api.iconify.design/lucide/calendar.svg?color=%230A8494" width="16" height="16" align="absmiddle" /></code>
  </p>

  

  <br />

  <img src="https://capsule-render.vercel.app/api?type=rect&height=3&color=0:0D0D0D,35:F58220,65:0A8494,100:0D0D0D" alt="Divider" width="100%" />

</div>

<br />

## Main Features

<table>
  <tr>
    <td width="50%" valign="top">
      <h3><img src="https://api.iconify.design/lucide/target.svg?color=%23F58220" width="20" height="20" align="absmiddle" />  Custom Learning Goals</h3>
      <p>Choose what you want to learn and commit to a <strong>Week</strong>, <strong>Month</strong>, or <strong>Year</strong> timeframe. Updating your goal starts you fresh by resetting your active streak.</p>
    </td>
    <td width="50%" valign="top">
      <h3><img src="https://api.iconify.design/lucide/flame.svg?color=%23F58220" width="20" height="20" align="absmiddle" />  32-Hour Streak Window</h3>
      <p>Log your daily learning session with a single tap. If more than <strong>32 hours</strong> pass without logging or freezing, your streak resets automatically.</p>
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <h3><img src="https://api.iconify.design/lucide/snowflake.svg?color=%230A8494" width="20" height="20" align="absmiddle" />  Smart Streak Freezes</h3>
      <p>Protect your streak on busy days with duration-based freeze allowances:<br />
      • <strong>Week:</strong> <code>2 Freezes</code><br />
      • <strong>Month:</strong> <code>8 Freezes</code><br />
      • <strong>Year:</strong> <code>96 Freezes</code></p>
    </td>
    <td width="50%" valign="top">
      <h3><img src="https://api.iconify.design/lucide/clock.svg?color=%230A8494" width="20" height="20" align="absmiddle" />  Automatic 12:00 AM Reset</h3>
      <p>Once a day is logged or frozen, buttons lock for the rest of the day and re-enable at <strong>12:00 AM midnight</strong>—even if logged at 11:00 PM.</p>
    </td>
  </tr>
</table>

<p>
  <img src="https://api.iconify.design/lucide/type.svg?color=%23F58220" width="18" height="18" align="absmiddle" />  <strong>Context-Aware Grammar:</strong> Dynamic UI labels automatically adapt between singular (<code>1 Day</code>) and plural (<code>2 Days</code>, <code>3 Days</code>) across both streak and freeze counters.
</p>

<br />

## App Preview

<div align="center">
  <img src="assets/screenshot.png" alt="Learning App Activity Screen" width="300" />
</div>

<br />

## Technologies Used

- **SwiftUI** — Declarative dark-mode user interface and custom circular controls
- **SwiftData** — Local persistence for goals, daily activity logs, and freeze counts
- **MVVM Architecture** — Clean separation between state logic (`LearningViewModel`) and views (`ActivityView`)
- **Foundation (`Calendar` and `Timer`)** — Exact midnight rollover calculations and 32-hour inactivity checks

<br />

<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=rect&height=3&color=0:0D0D0D,35:0A8494,65:F58220,100:0D0D0D" alt="Footer Divider" width="100%" />
</div>
