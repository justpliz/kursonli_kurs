// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".
import { Socket } from "phoenix"
// Bring in Phoenix channels client library:
const Toast = Swal.mixin({
  toast: true,
  position: 'top-end',
  showConfirmButton: false,
  timer: 3000,
  timerProgressBar: true,
  didOpen: (toast) => {
    toast.addEventListener('mouseenter', Swal.stopTimer)
    toast.addEventListener('mouseleave', Swal.resumeTimer)
  }
})

const getWorker = () => {
  return JSON.parse(localStorage.getItem("worker"))
}
$(function () {
  let socket = new Socket("/socket", {
    logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) })
  })
  socket.connect({ user_id: "123" })

  // Now that you are connected, you can join channels with a topic.
  // Let's assume you have a channel with a topic named `room` and the
  // subtopic is its id - in this case 42:
  let channel = socket.channel("rooms:lobby", {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  const templateChatNewMe = (body, name) => {
    const html = `
      <div class="flex w-full mt-2 space-x-3 max-w-xs">
      <div class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"></div>
      <div>
         <div class="bg-gray-300 p-3 rounded-r-lg rounded-bl-lg">
            <p class="text-sm" id="text">${body}</p>
         </div>
         <span class="text-xs text-gray-500 leading-none">${name}</span>
      </div>
      </div>`
    const elem = document.querySelector("#chatWrapper")
    elem.insertAdjacentHTML("beforeend", html)
  }

  const templateChatYour = (body, name) => {
    const html = `
      <div class="flex w-full mt-2 space-x-3 max-w-xs ml-auto justify-end">
      <div>
         <div class="bg-blue-600 text-white p-3 rounded-l-lg rounded-br-lg">
            <p class="text-sm">${body}</p>
         </div>
         <span class="text-xs text-gray-500 leading-none">${name}</span>
      </div>
      <div class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"></div>
    </div>`
    const elem = document.querySelector("#chatWrapper")
    elem.insertAdjacentHTML("beforeend", html)
  }

  $("#chat").keypress(function (e) {
    var key = e.which;

    if (key == 13)  // the enter key code
    {
      channel.push("new:msg", { body: this.value, worker: getWorker() })
      this.value = ""

    }
  });

  channel.on("new:msg", payload => {
    const worker = getWorker()
    console.log(payload)
    if (worker.id == payload.user.id) {
      templateChatYour(payload.body, payload.user.first_name)
    }
    else {
      templateChatNewMe(payload.body, payload.user.first_name)
    }
  })
  channel.on("notify", payload => {

    Toast.fire({
      title: payload.notify,
      icon: "success",
    })
  })
})
