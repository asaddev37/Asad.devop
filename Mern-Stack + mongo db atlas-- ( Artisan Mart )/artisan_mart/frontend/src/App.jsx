import React from 'react';

function App() {
  // Add CSS keyframes for horizontal sliding carousel
  const carouselKeyframes = `
    @keyframes slideLeft {
      0% {
        transform: translateX(0);
      }
      100% {
        transform: translateX(-2700px);
      }
    }
  `;

  // Inject keyframes into document head
  React.useEffect(() => {
    const style = document.createElement('style');
    style.textContent = carouselKeyframes;
    document.head.appendChild(style);
    return () => document.head.removeChild(style);
  }, []);

  const styles = {
    container: {
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      lineHeight: '1.6',
      color: '#333',
      margin: 0,
      padding: 0
    },
    header: {
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      color: 'white',
      padding: '1rem 0',
      position: 'fixed',
      top: 0,
      width: '100%',
      zIndex: 1000,
      boxShadow: '0 2px 10px rgba(0,0,0,0.1)'
    },
    nav: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      maxWidth: '1200px',
      margin: '0 auto',
      padding: '0 2rem'
    },
    logo: {
      fontSize: '1.5rem',
      fontWeight: 'bold',
      textDecoration: 'none',
      color: 'white'
    },
    navLinks: {
      display: 'flex',
      gap: '2rem',
      listStyle: 'none',
      margin: 0,
      padding: 0
    },
    navLink: {
      color: 'white',
      textDecoration: 'none',
      transition: 'opacity 0.3s',
      cursor: 'pointer'
    },
    hero: {
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      color: 'white',
      padding: '8rem 2rem 6rem',
      textAlign: 'center',
      marginTop: '70px'
    },
    heroContent: {
      maxWidth: '800px',
      margin: '0 auto'
    },
    heroTitle: {
      fontSize: '3.5rem',
      fontWeight: 'bold',
      marginBottom: '1.5rem',
      lineHeight: '1.2'
    },
    heroSubtitle: {
      fontSize: '1.25rem',
      marginBottom: '3rem',
      opacity: 0.9
    },
    ctaButtons: {
      display: 'flex',
      gap: '1rem',
      justifyContent: 'center',
      flexWrap: 'wrap'
    },
    primaryBtn: {
      backgroundColor: '#ff6b6b',
      color: 'white',
      padding: '1rem 2rem',
      borderRadius: '50px',
      border: 'none',
      fontSize: '1.1rem',
      fontWeight: '600',
      cursor: 'pointer',
      transition: 'all 0.3s',
      boxShadow: '0 4px 15px rgba(255, 107, 107, 0.4)'
    },
    secondaryBtn: {
      backgroundColor: 'transparent',
      color: 'white',
      padding: '1rem 2rem',
      borderRadius: '50px',
      border: '2px solid white',
      fontSize: '1.1rem',
      fontWeight: '600',
      cursor: 'pointer',
      transition: 'all 0.3s'
    },
    features: {
      padding: '6rem 2rem',
      backgroundColor: '#f8f9fa'
    },
    featuresContainer: {
      maxWidth: '1200px',
      margin: '0 auto',
      textAlign: 'center'
    },
    sectionTitle: {
      fontSize: '2.5rem',
      fontWeight: 'bold',
      marginBottom: '1rem',
      color: '#333'
    },
    sectionSubtitle: {
      fontSize: '1.2rem',
      color: '#666',
      marginBottom: '4rem'
    },
    featuresGrid: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
      gap: '3rem',
      marginTop: '3rem'
    },
    featureCard: {
      backgroundColor: 'white',
      padding: '2.5rem',
      borderRadius: '15px',
      boxShadow: '0 10px 30px rgba(0,0,0,0.1)',
      transition: 'transform 0.3s'
    },
    featureIcon: {
      fontSize: '3rem',
      marginBottom: '1.5rem'
    },
    featureTitle: {
      fontSize: '1.5rem',
      fontWeight: 'bold',
      marginBottom: '1rem',
      color: '#333'
    },
    featureDesc: {
      color: '#666',
      lineHeight: '1.6'
    },
    stats: {
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      color: 'white',
      padding: '4rem 2rem',
      textAlign: 'center'
    },
    statsGrid: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
      gap: '2rem',
      maxWidth: '800px',
      margin: '0 auto'
    },
    statItem: {
      padding: '1rem'
    },
    statNumber: {
      fontSize: '3rem',
      fontWeight: 'bold',
      marginBottom: '0.5rem'
    },
    statLabel: {
      fontSize: '1.1rem',
      opacity: 0.9
    },
    cta: {
      padding: '6rem 2rem',
      backgroundColor: '#fff',
      textAlign: 'center'
    },
    // 3D Carousel Styles
    carousel: {
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)',
      padding: '120px 0',
      overflow: 'hidden',
      width: '100vw',
      marginLeft: 'calc(-50vw + 50%)',
      position: 'relative',
    },
    carouselContainer: {
      height: '600px',
      display: 'flex',
      alignItems: 'center',
      marginTop: '0',
      width: '100%',
      overflow: 'hidden',
      position: 'relative',
    },
    carouselTrack: {
      display: 'flex',
      width: 'calc(420px * 12)',
      height: '520px',
      animation: 'slideLeft 20s infinite linear',
      gap: '30px',
    },
    carouselItem: {
      flex: '0 0 420px',
      width: '420px',
      height: '520px',
      borderRadius: '25px',
      overflow: 'hidden',
      boxShadow: '0 20px 40px rgba(0,0,0,0.3)',
      transition: 'transform 0.3s ease',
      cursor: 'pointer',
      border: '2px solid rgba(255,255,255,0.2)',
      position: 'relative',
    },
    carouselImage: {
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      transition: 'transform 0.3s ease',
    },
    carouselOverlay: {
      position: 'absolute',
      bottom: '0',
      left: '0',
      right: '0',
      background: 'linear-gradient(transparent, rgba(0,0,0,0.8))',
      color: 'white',
      padding: '20px',
      transform: 'translateY(100%)',
      transition: 'transform 0.3s ease',
    },
    carouselTitle: {
      fontSize: '1.25rem',
      fontWeight: 'bold',
      marginBottom: '5px',
    },
    carouselDesc: {
      fontSize: '0.9rem',
      opacity: '0.9',
    },
    footer: {
      backgroundColor: '#333',
      color: 'white',
      padding: '3rem 2rem 1rem',
      textAlign: 'center'
    }
  };

  return (
    <div style={styles.container}>
      {/* Header */}
      <header style={styles.header}>
        <nav style={styles.nav}>
          <a href="#" style={styles.logo}>🎨 Artisan Mart</a>
          <ul style={styles.navLinks}>
            <li><a href="#" style={styles.navLink}>Home</a></li>
            <li><a href="#" style={styles.navLink}>Products</a></li>
            <li><a href="#" style={styles.navLink}>Artists</a></li>
            <li><a href="#" style={styles.navLink}>About</a></li>
            <li><a href="#" style={styles.navLink}>Contact</a></li>
          </ul>
        </nav>
      </header>

      {/* 3D Carousel Section */}
      <section style={styles.carousel}>
        <div style={styles.featuresContainer}>
          <h2 style={styles.sectionTitle}>Featured Handcrafted Products</h2>
          <p style={styles.sectionSubtitle}>Explore our curated collection of artisan masterpieces</p>
          
          <div style={styles.carouselContainer}>
            <div style={styles.carouselTrack}>
               {/* First set of images */}
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=420&h=520&fit=crop&crop=center" 
                   alt="Handcrafted Pottery" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Artisan Pottery</h3>
                   <p style={styles.carouselDesc}>Handmade ceramic masterpieces</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=420&h=520&fit=crop&crop=center" 
                   alt="Handmade Jewelry" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Handmade Jewelry</h3>
                   <p style={styles.carouselDesc}>Unique accessories crafted with love</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=420&h=520&fit=crop&crop=center" 
                   alt="Woven Textiles" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Woven Textiles</h3>
                   <p style={styles.carouselDesc}>Traditional patterns, modern style</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=420&h=520&fit=crop&crop=center" 
                   alt="Wooden Crafts" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Wooden Crafts</h3>
                   <p style={styles.carouselDesc}>Sustainable wood artistry</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1544441893-675973e31985?w=420&h=520&fit=crop&crop=center" 
                   alt="Glass Art" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Glass Art</h3>
                   <p style={styles.carouselDesc}>Blown glass perfection</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=420&h=520&fit=crop&crop=center" 
                   alt="Leather Goods" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Leather Goods</h3>
                   <p style={styles.carouselDesc}>Premium handcrafted leather</p>
                 </div>
               </div>
               
               {/* Duplicate set for seamless loop */}
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=420&h=520&fit=crop&crop=center" 
                   alt="Handcrafted Pottery" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Artisan Pottery</h3>
                   <p style={styles.carouselDesc}>Handmade ceramic masterpieces</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=420&h=520&fit=crop&crop=center" 
                   alt="Handmade Jewelry" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Handmade Jewelry</h3>
                   <p style={styles.carouselDesc}>Unique accessories crafted with love</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=420&h=520&fit=crop&crop=center" 
                   alt="Woven Textiles" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Woven Textiles</h3>
                   <p style={styles.carouselDesc}>Traditional patterns, modern style</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=420&h=520&fit=crop&crop=center" 
                   alt="Wooden Crafts" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Wooden Crafts</h3>
                   <p style={styles.carouselDesc}>Sustainable wood artistry</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1544441893-675973e31985?w=420&h=520&fit=crop&crop=center" 
                   alt="Glass Art" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Glass Art</h3>
                   <p style={styles.carouselDesc}>Blown glass perfection</p>
                 </div>
               </div>
               
               <div 
                 style={styles.carouselItem}
                 onMouseEnter={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(0)';
                 }}
                 onMouseLeave={(e) => {
                   const overlay = e.currentTarget.querySelector('.carousel-overlay');
                   if (overlay) overlay.style.transform = 'translateY(100%)';
                 }}
               >
                 <img 
                   src="https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=420&h=520&fit=crop&crop=center" 
                   alt="Leather Goods" 
                   style={styles.carouselImage}
                 />
                 <div className="carousel-overlay" style={styles.carouselOverlay}>
                   <h3 style={styles.carouselTitle}>Leather Goods</h3>
                   <p style={styles.carouselDesc}>Premium handcrafted leather</p>
                 </div>
               </div>
            </div>
          </div>
        </div>
      </section>

      {/* Hero Section */}
      <section style={styles.hero}>
        <div style={styles.heroContent}>
          <h1 style={styles.heroTitle}>Discover Unique Handcrafted Treasures</h1>
          <p style={styles.heroSubtitle}>
            Connect with talented artisans and discover one-of-a-kind handmade products that tell a story
          </p>
          <div style={styles.ctaButtons}>
            <button 
              style={styles.primaryBtn}
              onMouseOver={(e) => e.target.style.transform = 'translateY(-2px)'}
              onMouseOut={(e) => e.target.style.transform = 'translateY(0)'}
            >
              Explore Products
            </button>
            <button 
              style={styles.secondaryBtn}
              onMouseOver={(e) => {
                e.target.style.backgroundColor = 'white';
                e.target.style.color = '#667eea';
              }}
              onMouseOut={(e) => {
                e.target.style.backgroundColor = 'transparent';
                e.target.style.color = 'white';
              }}
            >
              Become an Artist
            </button>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section style={styles.features}>
        <div style={styles.featuresContainer}>
          <h2 style={styles.sectionTitle}>Why Choose Artisan Mart?</h2>
          <p style={styles.sectionSubtitle}>Experience the difference of authentic handcrafted goods</p>
          
          <div style={styles.featuresGrid}>
            <div 
              style={styles.featureCard}
              onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-5px)'}
              onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <div style={styles.featureIcon}>🎨</div>
              <h3 style={styles.featureTitle}>Unique Creations</h3>
              <p style={styles.featureDesc}>
                Every piece is carefully handcrafted by skilled artisans, ensuring you get truly unique items that can't be found anywhere else.
              </p>
            </div>
            
            <div 
              style={styles.featureCard}
              onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-5px)'}
              onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <div style={styles.featureIcon}>🌱</div>
              <h3 style={styles.featureTitle}>Sustainable & Ethical</h3>
              <p style={styles.featureDesc}>
                Support sustainable practices and fair trade. Our artisans use eco-friendly materials and traditional techniques.
              </p>
            </div>
            
            <div 
              style={styles.featureCard}
              onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-5px)'}
              onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <div style={styles.featureIcon}>❤️</div>
              <h3 style={styles.featureTitle}>Support Artists</h3>
              <p style={styles.featureDesc}>
                Directly support independent artists and craftspeople. Your purchase helps preserve traditional arts and crafts.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section style={styles.stats}>
        <div style={styles.statsGrid}>
          <div style={styles.statItem}>
            <div style={styles.statNumber}>10K+</div>
            <div style={styles.statLabel}>Happy Customers</div>
          </div>
          <div style={styles.statItem}>
            <div style={styles.statNumber}>500+</div>
            <div style={styles.statLabel}>Talented Artists</div>
          </div>
          <div style={styles.statItem}>
            <div style={styles.statNumber}>50K+</div>
            <div style={styles.statLabel}>Unique Products</div>
          </div>
          <div style={styles.statItem}>
            <div style={styles.statNumber}>25+</div>
            <div style={styles.statLabel}>Countries Served</div>
          </div>
        </div>
      </section>

      {/* Call to Action */}
      <section style={styles.cta}>
        <div style={styles.featuresContainer}>
          <h2 style={styles.sectionTitle}>Ready to Start Your Journey?</h2>
          <p style={styles.sectionSubtitle}>Join thousands of customers who have discovered the beauty of handcrafted goods</p>
          <button 
            style={{...styles.primaryBtn, fontSize: '1.2rem', padding: '1.2rem 3rem'}}
            onMouseOver={(e) => {
              e.target.style.transform = 'translateY(-2px)';
              e.target.style.boxShadow = '0 6px 20px rgba(255, 107, 107, 0.6)';
            }}
            onMouseOut={(e) => {
              e.target.style.transform = 'translateY(0)';
              e.target.style.boxShadow = '0 4px 15px rgba(255, 107, 107, 0.4)';
            }}
          >
            Start Shopping Now
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer style={styles.footer}>
        <p>&copy; 2024 Artisan Mart. Crafted with love for handmade excellence.</p>
      </footer>
    </div>
  );
}

export default App;