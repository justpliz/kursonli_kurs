import axios from "axios";
import toast from "./helper/toast";
import { getWorker } from "./user_socket";

export const handleDeleteChat = async (e) => {
  const id = e.currentTarget.dataset.channelid;
  const el = e.currentTarget;
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
};
