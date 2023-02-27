import axios from "axios";
import Toast from "./helper/toast";
$(".click-event").click(eventClick);
export async function eventClick() {
  const item = JSON.parse(this.dataset.item);
  item.type_event = this.dataset.type;
  await axios
    .post("/api/v1/trade", item)
    .then(() => {
      let element = document.querySelector(`[data-etsid="${item.ets_id}"]`);
      element.dataset.type = this.dataset.type;
      Toast.fire({
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        title: helperType(this.dataset.type),
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

function helperType(type) {
  if (type == "fail") {
    return "Вы отклонили сделку"
  }
  return "Вы приняли сделку"
}

