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
        tableGray: '#515151',
        dblue: '#000045',
        blub: '#3689ce',
        lightBlub: '#5699d1',
        greatGreen: '#A7FFB5',
        greatYellow: '#FFC69D',
        grey: '#f3f3f3',
      },
      minHeight: {
        '600': '600px',
        '60': '60px',
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
      },
      width: {
        '600': '600px',
        '1440': '1440px',
        '5p': '5%',
        '10p': '10%',
        '14p': '14%',
      },
      margin: {
        '2p': '0px'
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
