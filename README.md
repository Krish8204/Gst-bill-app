# GST Billing App

A Flutter-based GST Billing Application for TATA Retail Solutions that automates tax calculations, simplifies invoice generation, and maintains sales records.

## Features

- Add and manage products with their prices and GST rates
- Automatic calculation of CGST and SGST
- Real-time bill generation with itemized details
- Customer information management
- Persistent storage of products and bills
- User-friendly interface for cashiers
- Support for different GST slabs (5%, 12%, 18%, 28%)

## GST Calculation

The app automatically calculates the following for each product:
- CGST = (Price × GST %) / 2
- SGST = (Price × GST %) / 2
- Total Price = Price + CGST + SGST

## Setup Instructions

1. Ensure you have Flutter installed on your system. If not, follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).

2. Clone this repository:
   ```bash
   git clone <repository-url>
   cd gst_billing_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## System Requirements

- Flutter 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Supported platforms: Windows, macOS, Linux, Android, iOS

## Dependencies

- provider: ^6.0.5 - For state management
- sqflite: ^2.3.0 - For local database storage
- path: ^1.8.3 - For handling file paths
- intl: ^0.18.1 - For date and number formatting
- pdf: ^3.10.4 - For generating PDF bills
- path_provider: ^2.1.1 - For accessing device storage
- share_plus: ^7.1.0 - For sharing bills

## Usage

1. **Adding Products**:
   - Click the '+' button in the app bar
   - Enter product details (name, price, GST rate)
   - Click 'Add' to save the product

2. **Creating a Bill**:
   - Select products from the left panel
   - Enter quantity for each product
   - Add customer details (optional)
   - Click 'Generate Bill' to create the invoice

## Contributing

Feel free to submit issues and enhancement requests. 