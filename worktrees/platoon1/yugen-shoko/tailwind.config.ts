import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/**/*.{ts,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        // Ethereal Library デザインシステム
        // Light mode
        "washi-white": "#F9F8F6",
        "sumi-black": "#2D2D2D",
        "accent-murasaki": "#9D8CA1",
        "accent-kon": "#1B1F3B",
        // Dark mode
        "midnight": "#1A1A1A",
        "moonlight": "#E8E6E3",
        "accent-gold": "#C5A059",
        "accent-pale-gold": "#D4C4A0",
      },
      fontFamily: {
        sans: ["Noto Sans JP", "sans-serif"],
        serif: ["Noto Serif JP", "serif"],
      },
    },
  },
  plugins: [],
};

export default config;
