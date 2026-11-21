# Neeraj Expense

A multi-page Flutter expense and personal lending tracker.

## Pages

- **Home:** monthly spending, budget progress, money lent/owed, and a weekly trend.
- **Activity:** filter, review, and delete transactions.
- **Insights:** weekly, monthly, and rolling 12-month totals, averages, a trend chart, and category amounts with percentage shares.
- **Reports:** preview a period summary and download a PDF containing totals, category shares, lending balances, and all activity in the selected period.
- **Settings:** change the monthly budget and review where records are stored.

Expense entries include a required title, amount, date, and category. Categories include food, groceries, transport, shopping, bills, housing, health, entertainment, travel, education, personal care, subscriptions, gifts/donations, and other. Entries are saved on-device using `shared_preferences`.

The logo source is [neeraj_expense_logo.png](assets/images/neeraj_expense_logo.png). Launcher icons are generated for Android, iOS, macOS, Windows, and web.

## Run

```sh
flutter pub get
flutter run
```

## Sign-in setup

The welcome screen includes email/password, Google, and GitHub entry points. These currently open a local preview; they do not authenticate or sync user accounts. Connect an authentication service and configure OAuth credentials before using real accounts.
# expense
