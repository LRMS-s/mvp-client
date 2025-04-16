/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,ts}'],
  theme: {
    extend: {
      colors: {
        'lrms-primary': '#3B82F6',
        'lrms-secondary': '#10B981',
        'lrms-accent': '#6366F1',
        'lrms-neutral': '#4B5563',
      },
    },
  },
  plugins: [],
};
