import axios from "axios";
import toast from "./helper/toast";
import { getWorker } from "./user_socket";

export const handleDeleteChat = async (e) => {
  const id = e.currentTarget.dataset.channelid;
  const el = e.currentTarget;
  const userEl = document.querySelector(`[data-tagsid="${id}"]`);
  let channelId = "";
  const worker = getWorker();
  if (id > worker.id) {
    channelId = worker.id + id;
  } else {
    channelId = id + worker.id;
  }
  console.log(id);
  console.log(worker.id);
  await axios
    .delete("/api/v1/chat/" + channelId)
    .then((response) => {
      console.log(response);
      userEl.remove();
      el.remove();
      toast.fire({
        title: ``,
      });
    })
    .catch((response) => {
      console.log(response);
      toast.fire({
        title: `Ошибка сервера`,
      });
    });
};
