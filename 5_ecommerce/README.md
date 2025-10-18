# Ecommerce Clone

This repository contains a Flutter mobile clone of the GhorerBazar ecommerce UI with authentication and Supabase-backed data management. The implementation focuses on clean, minimal, professional screens and includes a cart/checkout flow and order history.

## Environment

Create a `.env` file in the project root with the following values:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Replace the placeholders with values from your Supabase project.

## Screenshots

Home Page:

<img width="320" height="520" alt="Home" src="https://github.com/user-attachments/assets/df20f912-d772-4cd6-a806-7092fac40c5c" />

Product Details:

<img width="320" height="520" alt="Product Details" src="https://github.com/user-attachments/assets/f34b8377-845f-48de-b422-54439d131150" />

Cart Page:

<img width="320" height="520" alt="Cart" src="https://github.com/user-attachments/assets/ad45c23c-6d4c-4156-bbd8-89aa99a95501" />

Checkout:

<img width="320" height="520" alt="Checkout" src="https://github.com/user-attachments/assets/5821f198-35b6-4336-99ef-4a9bc9266333" />

Order History:

<img width="320" height="520" alt="Order History" src="https://github.com/user-attachments/assets/73db083c-d00f-46a3-b1da-535b5464db8e" />

## Getting started

1. Create and configure a Supabase project.
2. Clone this repository and open the `5_ecommerce` folder:

```bash
git clone https://github.com/shadabtanjeed/IT-Tasks.git
cd IT-Tasks/5_ecommerce
```

3. Install dependencies and run the app:

```bash
flutter pub get
flutter run
```

## Notes

- The app expects product price fields as text in the database; prices are parsed in the app.
- To enable order persistence, create the `order_history` table in your Supabase (see `supabase_order_history_migration.sql`).
