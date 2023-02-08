// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".
import { Socket } from "phoenix";
// Bring in Phoenix channels client library:
import { eventClick } from "./click_event";
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
 
  const templateTagsInsert = (name, worker_id) => {
    const html = `<div
    class="text-xs d_flex items-center text-center font-bold leading-sm uppercase p-2 bg-gray-300 border w-auto border-gray-400 text-black justify-center worker_click" data-id="${worker_id}"
    "}">

    ${name}
 </div>`;
    setTimeout(() => {
      document.querySelector(`[data-id="${worker_id}"]`).addEventListener("click",  async (e) => (
     await   handleClickWorker(e, socket)
      ))

    }, 100)
    userConnectEl.insertAdjacentHTML("beforeend", html);
  };
  // $("#chat").keypress(function (e) {
  //   var key = e.which;

  //   if (key == 13 && this.value != "") {
  //     // the enter key code
  //     channel.push("new:msg", {
  //       body: this.value,
  //       worker: getWorker(),
  //       type: "text",
  //     });
  //     this.value = "";
  //   }
  // });

  // channel.on("new:msg", (payload) => {
  //   const worker = getWorker();

  //   setTimeout(() => {
  //     chatWrapper.scrollTop = chatWrapper.scrollHeight;
  //   }, 10);
  //   if (worker.id == payload.user.id) {
  //     templateChatYour(payload.body, payload.user.first_name);
  //   } else {
  //     audioObj.play();
  //     templateChatNewMe(payload.body, payload.user.first_name);
  //   }
  // });
  channel.on("user:entered", (payload) => {
    userConnectEl.innerHTML = "";
    payload.online_users.forEach((element) => {
      if (worker.id != element.id){
        templateTagsInsert(element.first_name, element.id);
      }
    });
  });
  channel.on("new:event", (payload) => {
    meowMix.play();
    templateEvent(payload);
  });
  channel.on("notify", (payload) => {
    audioObj.play();
    Toast.fire({
      title: payload.notify,
      icon: "success",
    });
  });
});
const templateEvent = (map) => {
  const html = `
  <div class="w-full mt-2 bg-blub p-4 text-white rounded  event"  data-etsid="${map.ets_id
    }" data-type='${map.type_event}'>
  <div class="text-gray-200">Ваш ордер на: ${map.item_order.volume}  ${map.item_order.currency_short_name
    }    по курсу ${map.item_order.course_sale}  </div>
  <div class="font-bold">Поступило предложение от ${map.item_order.worker_name
    }: ${map.item_order.organization}</div>
  <div class="text-gray-200">предложено ${map.volume} ${map.item_order.currency_short_name
    } по курсу ${map.item_order.course_sale}
  </div>
  <div class="w-full bg-white text-black text-center py-2 my-2 rounded" >
     Ваши условия: ${map.terms}
  </div>
  <div class="flex gap-2 buttons-event">
     <button class="bg-green-700 rounded w-full py-2 items-center justify-center flex click-event" data-type="success"  data-item='${JSON.stringify(
      map
    )}'>Принять</button>
     <button class="bg-red-600 rounded w-full py-2 items-center justify-center flex click-event" data-type="fail" data-item='${JSON.stringify(
      map
    )}'>Отклонить</button>
  </div>
</div>
  `;

  chatWrapper.insertAdjacentHTML("beforeend", html);
  setTimeout(() => {
    [
      ...document
        .querySelector(`[data-etsid="${map.ets_id}"]`)
        .querySelectorAll(".click-event"),
    ].forEach((e) => e.addEventListener("click", eventClick));
  }, 100);
};
