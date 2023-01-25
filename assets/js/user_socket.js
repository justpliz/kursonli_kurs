// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".
import { Socket } from "phoenix";
// Bring in Phoenix channels client library:

const audioObj = new Audio("/images/icq.mp3");
// audioObj.play()
const getWorker = () => {
  return JSON.parse(localStorage.getItem("worker"));
};
const userConnectEl = document.querySelector("#userConnect");
const worker = getWorker();
$(function () {
  let socket = new Socket("/socket", {
    logger: (kind, msg, data) => {
      console.log(`${kind}: ${msg}`, data);
    },
  });
  socket.connect({ user_id: worker.id, worker });

  // Now that you are connected, you can join channels with a topic.
  // Let's assume you have a channel with a topic named `room` and the
  // subtopic is its id - in this case 42:

  console.log(worker);
  let channel = socket.channel(`rooms:${worker.city.id}`, { worker: worker });
  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });
  const chatWrapper = document.querySelector("#chatWrapper");
  chatWrapper.scrollTop = chatWrapper.scrollHeight;
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
      </div>`;

    chatWrapper.insertAdjacentHTML("beforeend", html);
  };

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
    </div>`;

    chatWrapper.insertAdjacentHTML("beforeend", html);
  };
  const templateSystem = (name) => {
    const html = `
      <div class="flex w-full mt-2 space-x-3 max-w-xs ml-auto justify-end">
      <div>

         <span class="text-xs text-gray-500 leading-none">Подкючился -> ${name}</span>
      </div>
    </div>`;

    chatWrapper.insertAdjacentHTML("beforeend", html);
  };
  const templateTagsInsert = (name, worker_id) => {
    const html = `<div id="worker_id"
    class="text-xs items-center  text-center font-bold leading-sm uppercase p-1 bg-blue-200 text-blue-700 rounded-full justify-center">

    ${name}
 </div>`;
    userConnectEl.insertAdjacentHTML("beforeend", html);
  };
  $("#chat").keypress(function (e) {
    var key = e.which;

    if (key == 13 && this.value != "") {
      // the enter key code
      channel.push("new:msg", {
        body: this.value,
        worker: getWorker(),
        type: "text",
      });
      this.value = "";
    }
  });

  channel.on("new:msg", (payload) => {
    const worker = getWorker();
    setTimeout(() => {
      chatWrapper.scrollTop = chatWrapper.scrollHeight;
    }, 10);

    if (worker.id == payload.user.id) {
      templateChatYour(payload.body, payload.user.first_name);
    } else {
      audioObj.play();
      templateChatNewMe(payload.body, payload.user.first_name);
    }
  });
  channel.on("user:entered", (payload) => {
    userConnectEl.innerHTML = "";
    payload.online_users.forEach((element) => {
      templateTagsInsert(element.first_name, element.id);
    });
  });
  channel.on("notify", (payload) => {
    audioObj.play();
    Toast.fire({
      title: payload.notify,
      icon: "success",
    });
  });
});
