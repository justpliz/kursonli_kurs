// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".
import { Socket } from "phoenix";
// Bring in Phoenix channels client library:
import { eventClick } from "./click_event";
import { templateNewOrder } from "./template/new_order";
import { handleClickWorker } from "./worker_click";
const meowMix = new Audio("/images/sound/notice.mp3");
const audioObj = new Audio(
  "/images/sound/notice.mp3"
);
// audioObj.play()
export const getWorker = () => {
  return JSON.parse(localStorage.getItem("worker"));
};
const userConnectEl = document.querySelector("#userConnect");

$(function () {
  const worker = getWorker();
  let socket = new Socket("/socket", {
    // logger: (kind, msg, data) => {
    // },
  });
  socket.connect({ user_id: worker.id, worker });

  // Now that you are connected, you can join channels with a topic.
  // Let's assume you have a channel with a topic named `room` and the
  // subtopic is its id - in this case 42:

  let channelOnline = socket.channel(`online:${worker.id}`);
  channelOnline
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });
    channelOnline.on("new:change_color", (payload) => {
      console.log("payload", payload)
      document.querySelector(`[data-etsid='${payload.data.ets_id}']`).dataset.type = payload.data.type_event
    });
  channelOnline.on("leave", () => {
    console.log("LEAVE -------");
    localStorage.removeItem("worker");
    window.location.href = "/worker/logout";
  });
  channelOnline.on("notification", (payload) => {
    meowMix.play();
    Toast.fire({
      title: payload.message,
      icon: "success",
      showConfirmButton: false,
      timer: 5000,
      timerProgressBar: true,
    });
  });
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
  console.log("USER SOCKET 123")
  const templateTagsInsert = (name, worker_id) => {

    const html = `<div
    class="text-xs flex items-center text-center font-bold leading-sm uppercase p-2 bg-gray-300 border w-auto border-gray-400 text-black justify-center worker_click" data-tagsid="${worker_id}"
    "}">

    ${name}
 </div>`;
    setTimeout(() => {
      const etsElement =  document.querySelector(`[data-tagsid="${worker_id}"]`)
      etsElement.addEventListener("click", async (e) => (
        await handleClickWorker(e, socket, etsElement)
      ))

    }, 100)
    userConnectEl.insertAdjacentHTML("beforeend", html);
  };
  $("#chat").keypress(function (e) {
    // var key = e.which;

    // if (key == 13 && this.value != "") {
    //   // the enter key code
    //   channel.push("new:msg", {
    //     body: this.value,
    //     worker: getWorker(),
    //     type: "text",
    //   });
    //   this.value = "";
    // }
  });

  channel.on("new:msg", (payload) => {
    console.log("NEW MSG USER")
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
  channelOnline.on("user:entered", (payload) => {
    userConnectEl.innerHTML = "";
    console.log(payload)
    payload.data.forEach((element) => {
      if (worker.id != element.channel_id) {
        templateTagsInsert(element.worker_name, element.channel_id);
      }
    });
  });

  channel.on("new:order", (payload) => {
    templateNewOrder(payload.data)
  });
 
  channel.on("notify", (payload) => {
    audioObj.play();
    Toast.fire({
      title: payload.notify,
      icon: "success",
    });
  });
});

