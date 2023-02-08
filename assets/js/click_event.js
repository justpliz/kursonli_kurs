import axios from "axios";
import Toast from "./helper/toast";
$(".click-event").click(eventClick);
export async function eventClick() {
  console.log(this);
  const item = JSON.parse(this.dataset.item);
  item.type_event = this.dataset.type;
  console.log(item);
  await axios
    .post("/api/v1/trade", item)
    .then(() => {
      let element = document.querySelector(`[data-etsid="${item.ets_id}"]`);
      element.dataset.type = this.dataset.type;
      Toast.fire({
        showConfirmButton: false,
        timer: 5000,
        timerProgressBar: true,
        title: "Вы успешно приняли сделку",
        icon: "success",
      });
    })
    .catch((e) => {
      Toast.fire({
        title: "Ошибка",
        icon: "error",
      });
    });
}
