import axios from "axios";
import Toast from "./helper/toast";
$(".click-event").click(async function () {
  const item = JSON.parse(this.dataset.item);
  item.type_event = this.dataset.type;
  console.log(item);
  await axios
    .post("/api/v1/trade", item)
    .then(() => {
      let element = document.querySelector(`[data-etsid="${item.ets_id}"]`);
      element.dataset.type = this.dataset.type;
      Toast.fire({
        title: "Вы успешно приняли ордер",
        icon: "success",
      });
    })
    .catch((e) => {
      Toast.fire({
        title: "Ошибка",
        icon: "error",
      });
    });
});