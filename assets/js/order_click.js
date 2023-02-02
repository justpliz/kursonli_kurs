const Toast = Swal.mixin({
  toast: true,
  position: "top-right",
  showConfirmButton: true,
});
const getWorker = () => {
  return JSON.parse(localStorage.getItem("worker"));
};
$(".order-click").click(function () {
  $(".order-click").removeClass("selected");
  $(this).addClass("selected");

  const item = JSON.parse(this.dataset.item);

  console.log(item);
  $("#org_title .name").text(item.worker_name);
  $("#org_title .title").text(item.filial_address);
  $("#org_title .phone").text(item.phone);
  document.querySelector("#accept").dataset.item = this.dataset.item;
});

$("#accept").click(function () {
  if (this.dataset.item == "") {
    Toast.fire({
      title: "Вы не выбрали ордер",
      icon: "error",
    });
    return "";
  }
  const crftoken = document.querySelector("#crf_token").value;
  const item = JSON.parse(this.dataset.item);
  console.log(item);
  const {
    course_purchase,
    course_sale,
    currency_short_name,
    date,
    filial_id,
    id,
    organization,
    terms,
    volume,
    transfer,
    type,
    worker_id,
  } = item;

  let itemSale = "";
  let itemSaleH1 = "";
  if (type == "sale") itemSale = "Вы продаете:";
  else itemSale = "Вы покупаете:";

  if (type == "sale") itemSaleH1 = "Укажите сумму продажи:";
  else itemSaleH1 = "Укажите сумму покупки:";
  console.log(item);
  item.worker = getWorker();
  if (getWorker().id != worker_id) {
    Swal.fire({
      showCloseButton: true,
      html: `
        <form action="/trades" method="post">
        <input name="_csrf_token" type="hidden" value="${crftoken}">
        <div> 
          <h1 class="title pos">Ордер на покупку<h1>
          <div>
            <label class="label_input pos">${itemSaleH1} </label>
            <input class="input_full number_input_only" id="volume_model" name="volume" required="true" type="text" maxlength="30">
          </div>
          <h3 class="pos gap-1"> ${itemSale} <span id="itemSale"> </span> по <span id="itemCourse"> </span></h3>
          <div class="pos gap-1"> 
            Итого:
            <span id="itemResult"></span>
          </div>

        <input class="input_full hidden number_input_only" name="order_id" value="${id}" required="true" type="text">
        <input  class="input_full hidden number_input_only" name="worker_id" value="${
          getWorker().id
        }" >
        <input  class="input_full hidden item_order" name="item_order" value='${JSON.stringify(
          item
        )}' >
        <label class="label_input pos">Условия:</label>
        <input class="input_full " name="terms" value="" required="true" type="text" maxlength="30">
      </div>
      <button type="submit" class="btn_save mt-2 pos">Подтвердить</button>
      </form>
        `,
      willOpen: () => {
        input();

        const volume_model = document.querySelector("#volume_model");
        const itemeSale = document.querySelector("#itemSale");
        const itemCourse = document.querySelector("#itemCourse");

        itemCourse.innerHTML = course_sale;
        const itemResult = document.querySelector("#itemResult");
        volume_model.addEventListener("input", (e) => {
          const volume = parseInt(e.currentTarget.value);
          const course_sale_float = parseFloat(course_sale);
          itemeSale.innerHTML = e.currentTarget.value;
          itemResult.innerHTML = volume * course_sale_float;
        });
      },
      showConfirmButton: false,
    });
  } else {
    Toast.fire({
      title: "Это ваш ордер!",
      icon: "error",
    });
  }
});

function input() {
  var input = [...document.querySelectorAll(".number_input_only")];
  input.forEach((el) => {
    el.addEventListener("input", (e) => {
      e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, "");
    });
  });
}

