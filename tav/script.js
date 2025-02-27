// Initialize Telegram Web App
window.Telegram.WebApp.ready();

// Expand the app to full height
window.Telegram.WebApp.expand();

// Optional: Adjust theme based on Telegram's color scheme
const theme = window.Telegram.WebApp.colorScheme;
document.body.style.backgroundColor = theme === 'dark' ? '#222' : '#f0f0f0';
document.querySelector('h1').style.color = theme === 'dark' ? '#fff' : '#333';
