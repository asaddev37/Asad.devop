<div align="center">

# 🎨 ArtisanMart
### A Multi-Vendor Marketplace for Artisans and Crafters

[![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Express.js](https://img.shields.io/badge/Express.js-404D59?style=for-the-badge)](https://expressjs.com/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Stripe](https://img.shields.io/badge/Stripe-008CDD?style=for-the-badge&logo=stripe&logoColor=white)](https://stripe.com/)

*A full-stack MERN marketplace connecting artisans with customers worldwide*

![ArtisanMart Showcase](https://via.placeholder.com/1200x600/4a7dff/ffffff?text=ArtisanMart+Marketplace)

</div>

## 🚀 Features

### For Shoppers
- 🛍️ Browse unique handmade products from multiple vendors
- 🔍 Advanced search and filtering by category, price, and ratings
- 🛒 Secure shopping cart with real-time updates
- 💳 Secure checkout with Stripe payment processing
- ⭐ Rate and review purchased items

### For Artisans
- 🏪 Create and manage your own storefront
- 📊 Track sales and customer interactions
- 💰 Get paid directly through Stripe Connect
- 📱 Mobile-responsive vendor dashboard

### For Administrators
- 👥 Manage vendors and users
- 📈 View platform analytics and sales reports
- ⚙️ Configure platform settings
- 🛡️ Moderate content and handle disputes

## 🛠️ Tech Stack

### Frontend
- **React** - Frontend library
- **React Router** - Navigation
- **Redux Toolkit** - State management
- **Tailwind CSS** - Styling
- **Axios** - HTTP client

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **JWT** - Authentication
- **Stripe** - Payment processing

## 🚀 Getting Started

### Prerequisites
- Node.js (v14 or later)
- MongoDB Atlas account or local MongoDB
- Stripe account for payment processing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/artisan-mart.git
   cd artisan-mart
   ```

2. **Install dependencies**
   ```bash
   # Install server dependencies
   cd backend
   npm install
   
   # Install client dependencies
   cd ../frontend
   npm install
   ```

3. **Set up environment variables**
   Create a `.env` file in the backend directory with:
   ```
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   STRIPE_SECRET_KEY=your_stripe_secret_key
   CLIENT_URL=http://localhost:3000
   ```

4. **Run the application**
   ```bash
   # Start backend server
   cd backend
   npm run dev
   
   # In a new terminal, start frontend
   cd frontend
   npm start
   ```

   The application will be available at `http://localhost:3000`

## 📸 Screenshots

| Feature | Preview |
|---------|---------|
| **Homepage** | ![Homepage](https://via.placeholder.com/400x250/4a7dff/ffffff?text=Homepage) |
| **Product Page** | ![Product Page](https://via.placeholder.com/400x250/4a7dff/ffffff?text=Product+Page) |
| **Vendor Dashboard** | ![Vendor Dashboard](https://via.placeholder.com/400x250/4a7dff/ffffff?text=Vendor+Dashboard) |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

Your Name - [@your_twitter](https://twitter.com/your_twitter) - your.email@example.com

Project Link: [https://github.com/yourusername/artisan-mart](https://github.com/yourusername/artisan-mart)

## 🙏 Acknowledgments

- [Font Awesome](https://fontawesome.com/)
- [React Icons](https://react-icons.github.io/react-icons/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Stripe](https://stripe.com/)
