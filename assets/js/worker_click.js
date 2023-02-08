const meowMix = new Audio("/images/sound/notice.mp3");
const audioObj = new Audio(
  "/images/sound/notice.mp3"
);
import { getWorker } from "./user_socket";
import axios from "axios";
import toast from "./helper/toast";
let chat = document.querySelector("#chat")
const loader = document.querySelector("#loader")
const chatWrapper = document.querySelector("#chatWrapper")
export const handleClickWorker =  async (event, socket ) => {
    const id = event.currentTarget.dataset.id
    if(id == getWorker().id) {
      
        toast.fire({
            title: "Абай крутой тмлид"
        })
        throw "На самом деле абай не крутой тимлид"
    }
    chat.replaceWith(chat.cloneNode(true))
     chat = document.querySelector("#chat")
    chatWrapper.innerHTML = ""
    loader.classList.toggle("hidden")
    let channel = socket.channel(`worker:${id}`);
    const result = await axios.get("/worker/chat/" + id)
    loader.classList.toggle("hidden")
    channel
        .join()
        .receive("ok", (resp) => {
            console.log("Joined successfully", resp);
        })
        .receive("error", (resp) => {
            console.log("Unable to join", resp);
        });

    console.log(result.data.chat_messages.forEach((el) => {
        if (worker.id == el.worker.id) {
            templateChatYour( el.body,  el.worker.first_name);
          } else {
            templateChatNewMe(el.body,  el.worker.first_name);
          }
  
    }))
    const handleChat = (e) => {
        var key = e.which;
        const element = e.currentTarget
        if (key == 13 && element.value != "") {
          // the enter key code
          channel.push("new:msg", {
            body: element.value,
            worker: getWorker(),
            type: "text",
          });
          element.value = "";
        }
      }
    chat.addEventListener("keydown", handleChat)
  
  chatWrapper.scrollTop = chatWrapper.scrollHeight;
  function templateChatNewMe (body, name) {
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

  function templateChatNewMe (body, name)  {
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
 
  function templateChatYour(body, name)  {
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
  chat.addEventListener("keydown", handleChat)

  channel.on("new:msg", (payload) => {
    const worker = getWorker();

    setTimeout(() => {
      chatWrapper.scrollTop = chatWrapper.scrollHeight;
    }, 10);
    if (worker.id == payload.user.id) {
      templateChatYour(payload.body, payload.user.first_name);
    } else {
      templateChatNewMe(payload.body, payload.user.first_name);
    }
  });

  channel.on("new:event", (payload) => {
    meowMix.play();
    templateEvent(payload);
  });
}
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