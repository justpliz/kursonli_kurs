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
        lightBlub: '#5699d1'
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
      },
      width: {
        '600': '600px',
      },
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
