/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    // fontFamily: {
    //   sans: ['Inter', 'sans-serif'],
    // },
    extend: {
      backgroundImage: {
        mainBg: "url('/src/assets/bg.jpg')",
      },
      boxShadow: {
        shadowPrimary: "2.6px 5.3px 5.3px hsl(0deg 0% 0% / 0.32)",
      },
      colors: {
        overlayPrimary: "rgba(58, 58, 58, 0.80)",
      },
    },
  },
  plugins: [],
};
