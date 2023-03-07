import translationsRU from '../../priv/gettext/rus/LC_MESSAGES/default.txt';
import translationsKZ from '../../priv/gettext/kaz/LC_MESSAGES/default.txt';

class Gettext {
  constructor(objectLoceles) {
    this.locales = objectLoceles
  }
  gettext(str) {
    const lang = localStorage.getItem("lang")
    const regex = new RegExp(`\msgid\\s"${str}"\nmsgstr\\s"\.+"`)
    const message = this.locales[lang].source.match(regex)
    console.log(message)
    if (message != null) {
      return message[0].replace(/msgid.+\nmsgstr\s"/, "").replace(/"$/, "")
    }
    else {
      return str
    }
  }
}
const gt = new Gettext({
  "kaz": {
    source: translationsKZ
  },
  "rus": {
    source: translationsRU
  }
})

export function gettext(str) {
  return gt.gettext(str)
}
