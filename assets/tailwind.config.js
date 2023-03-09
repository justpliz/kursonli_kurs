// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        drab: '#363740',
        tableGray: '#e3dbdb',
        dblue: '#000045',
        blub: '#3689ce',
        lightBlub: '#5699d1',
        greatGreen: '#67d368',
        greatYellow: '#FFC69D',
        grey: '#f3f3f3',
        accept: '#009640',
        index: '#ada3b6',
        indexYellow: '#f7ac3b',
        grayText: '#444444',
      },
      minHeight: {
        '600': '600px',
        '60': '60px',
        '300': '300px',
        '200': '200px',
      },
      maxHeight: {
        '58': '234px',
      },
      maxWidth: {
        '1440': '1440px',
      },
      minWidth: {
        '600': '600px',
      },
      height: {
        '600': '600px',
        '700': '700px',
        '2p': '2px',
        '58': '234px',
      },
      width: {
        '600': '600px',
        '1440': '1440px',
        '5p': '5%',
        '10p': '10%',
        '14p': '14%',
        '92': '92%',
      },
      margin: {
        '2p': '0px'
      },
      fontSize: {
        'small': '10px',
      },
      screens: {
        '2xl': { 'max': '1540px' },
        'note': { 'max': '1440px' },
        'xl': { 'max': '1280px' },
        'lg': { 'max': '1000px' },
        'md': { 'max': '769px' },
        'sm': { 'max': '640px' },
        'mb': { 'max': '768px' },
        'mob': { 'max': '441px' },
        'mobL': { 'max': '425px' },
        'mobS': { 'max': '375px' },
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({ addVariant }) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({ addVariant }) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
