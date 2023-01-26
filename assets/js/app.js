// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.


// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.

import { Socket } from "phoenix"
import "./user_socket"
import "./phone_input"
import "./order_click"
import "./multiselect.min"
// And connect to the path in "lib/kursonli_kurs_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.

import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
//import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())
window.Modalka = Swal.mixin({
   willOpen: (toast) => {
      var input = [...document.querySelectorAll('.number_input_only')];
      input.forEach((el) => {
         el.addEventListener("input", (e) => {
            e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, '');
         })
      });
      var multipleCancelButton = new Choices('#choices-multiple', {
         removeItemButton: true,
      });
      let phoneInputs = document.querySelectorAll('input[data-tel]');
      let getInputNumbersValue = function (input) {
         // Return stripped input value — just numbers
         return input.value.replace(/\D/g, '');
      }
      let onPhonePaste = function (e) {
         let input = e.target,
            inputNumbersValue = getInputNumbersValue(input);
         let pasted = e.clipboardData || window.clipboardData;
         if (pasted) {
            let pastedText = pasted.getData('Text');
            if (/\D/g.test(pastedText)) {
               // Attempt to paste non-numeric symbol — remove all non-numeric symbols,
               // formatting will be in onPhoneInput handler
               input.value = inputNumbersValue;
               return;
            }
         }
      }
      let onPhoneInput = function (e) {
         let input = e.target,
            inputNumbersValue = getInputNumbersValue(input),
            selectionStart = input.selectionStart,
            formattedInputValue = "";
         if (!inputNumbersValue) {
            return input.value = "";
         }
         if (input.value.length != selectionStart) {
            // Editing in the middle of input, not last symbol
            if (e.data && /\D/g.test(e.data)) {
               // Attempt to input non-numeric symbol
               input.value = inputNumbersValue;
            }
            return;
         }
         if (["7", "8", "9"].indexOf(inputNumbersValue[0]) > -1) {
            if (inputNumbersValue[0] == "9") inputNumbersValue = "7" + inputNumbersValue;
            let firstSymbols = (inputNumbersValue[0] == "8") ? "8" : "+7";
            formattedInputValue = input.value = firstSymbols + " ";
            if (inputNumbersValue.length > 1) {
               formattedInputValue += '(' + inputNumbersValue.substring(1, 4);
            }
            if (inputNumbersValue.length >= 5) {
               formattedInputValue += ') ' + inputNumbersValue.substring(4, 7);
            }
            if (inputNumbersValue.length >= 8) {
               formattedInputValue += '-' + inputNumbersValue.substring(7, 9);
            }
            if (inputNumbersValue.length >= 10) {
               formattedInputValue += '-' + inputNumbersValue.substring(9, 11);
            }
         } else {
            formattedInputValue = '+' + inputNumbersValue.substring(0, 16);
         }
         input.value = formattedInputValue;
      }
      let onPhoneKeyDown = function (e) {
         let inputValue = e.target.value.replace(/\D/g, '');
         if (e.keyCode == 8 && inputValue.length == 1) {
            e.target.value = "";
         }
      }
      for (let phoneInput of phoneInputs) {
         phoneInput.addEventListener('keydown', onPhoneKeyDown);
         phoneInput.addEventListener('input', onPhoneInput, false);
         phoneInput.addEventListener('paste', onPhonePaste, false);
      }
   }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

const activeLink = [...document.querySelectorAll(".active-link")]
const path = window.location
activeLink.forEach((e) => {
   if (e.href == path.href) {
      e.classList.add("active")
   }
})

function input() {
   var input = [...document.querySelectorAll('.number_input_only')];
   input.forEach((el) => {
      el.addEventListener("input", (e) => {
         e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, '');
      })
   });
}
input();


const inputOnePass = document.querySelector("#new_pass")
const inputTwoPass = document.querySelector("#re_new_pass")
const errosHtml = document.querySelector("#error")
const regSubmit = document.querySelector("#reg_submit")
const handleChange = (e) => {
   if (inputOnePass.value == inputTwoPass.value) {
      errosHtml.innerHTML = "<span class='text-green-600'>Пароли совпадают</span>"
      regSubmit.removeAttribute("disabled")
   } else {
      errosHtml.innerHTML = "<span class='text-red-600'>Пароль не верный</span>"
      regSubmit.setAttribute("disabled", "true")
   }
}
inputOnePass.addEventListener('input', handleChange)
inputTwoPass.addEventListener('input', handleChange)


$('#myModal').on('shown.bs.modal', function () {
   $('#myInput').trigger('focus')
})
