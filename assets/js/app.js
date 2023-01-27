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

import { Socket } from "phoenix";
import "./user_socket";
import "./phone_input";
import "./order_click";
import "./click_event";
import "./helper/modal_script";
// And connect to the path in "lib/kursonli_kurs_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.

import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
//import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

const activeLink = [...document.querySelectorAll(".active-link")];
const path = window.location;
activeLink.forEach((e) => {
  if (e.href == path.href) {
    e.classList.add("active");
  }
});

function input() {
  var input = [...document.querySelectorAll(".number_input_only")];
  input.forEach((el) => {
    el.addEventListener("input", (e) => {
      e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, "");
    });
  });
}
input();

const inputOnePass = document.querySelector("#new_pass");
const inputTwoPass = document.querySelector("#re_new_pass");
const errosHtml = document.querySelector("#error");
const regSubmit = document.querySelector("#reg_submit");
const handleChange = (e) => {
  if (inputOnePass.value == inputTwoPass.value) {
    errosHtml.innerHTML =
      "<span class='text-green-600'>Пароли совпадают</span>";
    regSubmit.removeAttribute("disabled");
  } else {
    errosHtml.innerHTML = "<span class='text-red-600'>Пароль не верный</span>";
    regSubmit.setAttribute("disabled", "true");
  }
};
inputOnePass.addEventListener("input", handleChange);
inputTwoPass.addEventListener("input", handleChange);

$("#myModal").on("shown.bs.modal", function () {
  $("#myInput").trigger("focus");
});
