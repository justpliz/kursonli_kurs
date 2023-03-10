import axios from "axios";
import toast from "./helper/toast";
import { getWorker } from "./user_socket";
import { gettext } from "./gettext";
export const handleDeleteChat = async (e) => {
  const id = e.currentTarget.dataset.channelid;
  const el = e.currentTarget;
  Modalka.fire({
    showConfirmButton: false,
    showCancelButton: false,
    showCloseButton: true,

    html: `
         <h1 class="title_without_margin text-left"> ${gettext(
           "Действительно удалить чат?"
         )} </h1>
       <div class="px-1">
             <div class="text-left my-4"> ${gettext(
               "Это действие необратимо. Вы действительно хотите удалить ваш чат?"
             )} </div>
             <div  class="btn_save cursor-pointer btn_delete_chat${id} my-2 pos w-fit"> ${gettext(
      "Удалить"
    )} </div>
       </div>
    `,
    didOpen: () => {
      const btn_delete_chat = document.querySelector(`.btn_delete_chat${id}`);
      btn_delete_chat.addEventListener("click", async () => {
        const chatWrapper = document.querySelector("#chatWrapper");
        chatWrapper.innerHTML = "Выберите чат для общения";
        const userEl = document.querySelector(`[data-tagsid="${id}"]`);
        let channelId = "";
        const worker = getWorker();
        if (id > worker.id) {
          channelId = worker.id + id;
        } else {
          channelId = id + worker.id;
        }
        let chat = document.querySelector("#chat");
        chat.replaceWith(chat.cloneNode(true));
        console.log(id);
        console.log(worker.id);
        await axios
          .delete("/api/v1/chat/", {
            params: {
              id: channelId,
              user_id: worker.id,
            },
          })
          .then((response) => {
            console.log(response);
            userEl.remove();
            el.remove();
            toast.fire({
              title: `Вы успешно удалили чат!`,
              icon: "success",
            });
          })
          .catch((response) => {
            console.log(response);
            toast.fire({
              title: `Ошибка сервера`,
              icon: "error",
            });
          });
      });
    },
  });
};
