const meowMix = new Audio("/images/sound/notice.mp3");
const audioObj = new Audio("/images/sound/notice.mp3");
import { getWorker } from "./user_socket";
import axios from "axios";
import toast from "./helper/toast";
import { eventClick } from "./click_event";
let chat = document.querySelector("#chat");
const loader = document.querySelector("#loader");
const chatWrapper = document.querySelector("#chatWrapper");

export const handleClickWorker = async (event, socket) => {
  const id = event.currentTarget.dataset.tagsid;
  const elements = [...document.querySelectorAll(`[data-tagsid]`)];
  elements.forEach((el) => {
    el.classList.remove("active");
  });
  event.currentTarget.classList.add("active");
  const worker = getWorker();
  let channelId = "";
  if (id > worker.id) {
    channelId = worker.id + id;
  } else {
    channelId = id + worker.id;
  }
  console.log("channelId", channelId);
  if (id == getWorker().id) {
    toast.fire({
      title: "Абай крутой тмлид",
    });
    throw "На самом деле абай не крутой тимлид";
  }
  chat.replaceWith(chat.cloneNode(true));
  chat = document.querySelector("#chat");
  chatWrapper.innerHTML = "";
  loader.classList.toggle("hidden");
  let channel = socket.channel(`worker:${channelId}`, {
    worker_id: id,
  });

  const result = await axios.get("/worker/chat", {
    params: {
      user_id: worker.id,
      worker_id: id,
    },
  });
  loader.classList.toggle("hidden");
  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  result.data.chat_messages.forEach((el) => {
    const isVisibleMessage = el["is_visible"][worker.id];
    if (worker.id == el.worker.id && el.type == "text" && isVisibleMessage) {
      templateChatYour(el.body, el.worker.first_name);
    } else if (
      worker.id != el.worker.id &&
      el.type == "text" &&
      isVisibleMessage
    ) {
      templateChatNewMe(el.body, el.worker.first_name);
    } else if (
      worker.id != el.worker_id &&
      el.type == "event" &&
      isVisibleMessage
    ) {
      templateEvent(el);
    } else if (
      worker.id == el.worker_id &&
      el.type == "event" &&
      isVisibleMessage
    ) {
      templateEvent1(el);
    }
  });
  const handleChat = (e) => {
    var key = e.which;
    const element = e.currentTarget;
    if (key == 13 && element.value != "") {
      // the enter key code
      channel.push("new:msg", {
        body: element.value,
        worker: getWorker(),
        type: "text",
      });
      element.value = "";
    }
  };
  chat.addEventListener("keydown", handleChat);

  chatWrapper.scrollTop = chatWrapper.scrollHeight;

  function templateChatNewMe(body, name) {
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
  }

  function templateChatYour(body, name) {
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
  }

  chat.addEventListener("keydown", handleChat);

  channel.on("new:msg", (payload) => {
    console.log("NEW MSG WORKER");
    const worker = getWorker();
    console.log(payload);
    setTimeout(() => {
      chatWrapper.scrollTop = chatWrapper.scrollHeight;
    }, 10);
    if (worker.id == payload.user.id) {
      templateChatYour(payload.body, payload.user.first_name);
    } else {
      templateChatNewMe(payload.body, payload.user.first_name);
    }
    meowMix.play();
  });

  channel.on("new:event", (payload) => {
    console.log("NEW EVENT WORKER");
    if (payload.worker_id != worker.id) {
      templateEvent(payload);
    } else {
      templateEvent1(payload);
    }
    meowMix.play();
  });
};

const templateEvent = (map) => {
  console.log("map", map);
  if (map.item_order.type == "sale") {
    item_order_type = "Продажу";
  } else {
    item_order_type = "Покупку";
  }
  const html = `
    <div class="w-full mt-2 bg-blub p-4 text-white rounded event" data-etsid="${
      map.ets_id
    }" data-type='${map.type_event}'>
    <div class="text-gray-200">На ваш ордер на ${item_order_type}: ${
    map.item_order.volume
  }  ${map.item_order.currency_short_name}    по курсу ${
    map.item_order.course_sale
  }  </div>
    <div class="font-bold">Поступило предложение от ${
      map.item_order.worker.first_name
    }: ${map.item_order.worker.filial_name}</div>
    <div class="text-gray-200">предложено ${map.volume} ${
    map.item_order.currency_short_name
  } по курсу ${map.item_order.course_sale}
    </div>
    <div class="w-full bg-white text-black text-center py-2 my-2 rounded" >
       Ваши условия: ${map.item_order.terms}
    </div>
    <div class="w-full bg-white text-black text-center py-2 my-2 rounded" >
       Условия от ${map.item_order.worker.filial_name}: ${map.terms}
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

const templateEvent1 = (map) => {
  if (map.item_order.type == "sale") {
    item_order_type = "Продажу";
  } else {
    item_order_type = "Покупку";
  }
  const html = `
    <div class="w-full mt-2 bg-blub p-4 text-white rounded event" data-loading="${map.type_event}" data-etsid="${map.ets_id}" data-type='${map.type_event}'>
    <div class="text-gray-200">Вы приняли ордер на: ${map.item_order.volume}  ${map.item_order.currency_short_name}    по курсу ${map.item_order.course_sale}  </div>
    <div class="font-bold">ордер от ${map.item_order.worker_name}: ${map.item_order.organization}</div>
    <div class="text-gray-200">предложено ${map.volume} ${map.item_order.currency_short_name} по курсу ${map.item_order.course_sale}
    </div>
    <div class="w-full bg-white text-black text-center py-2 my-2 rounded loading-event d_none">
      Ожидает подтверждения
    </div>
    <div class="w-full bg-white text-black text-center py-2 my-2 rounded active-event d_none">
      Сделка успешно завершена
    </div>
    <div class="w-full bg-white text-black text-center py-2 my-2 rounded fail-event d_none">
     Отказано
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
