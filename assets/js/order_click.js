const Toast = Swal.mixin({
  toast: true,
  position: "top-right",
  showConfirmButton: true,
});

const getWorker = () => {
  return JSON.parse(localStorage.getItem("worker"));
};
export function order_click(e) {
  $(".order-click").removeClass("selected");
  $(this).addClass("selected");

  const item = JSON.parse(this.dataset.item);

  $("#org_title .name").text(item.worker_name);
  $("#org_title .address").text(item.fililal_address);
  $("#org_title .phone").text(item.worker_phone);
  $("#org_title .phone").attr("href", `tel:${item.worker_phone}`);
  document.querySelector("#accept").dataset.item = this.dataset.item;
}
$(".order-click").click(order_click);

$("#accept").click(function () {
  if (this.dataset.item == "") {
    Toast.fire({
      title: "Вы не выбрали ордер",
      icon: "error",
      showConfirmButton: false,
      timer: 5000,
      timerProgressBar: true,
    });
    return "";
  }

  const crftoken = document.querySelector("#crf_token").value;
  const item = JSON.parse(this.dataset.item);
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
    limit,
    type,
    worker_id,
  } = item;

  let itemSale = "";
  let itemSaleH1 = "";
  let modalTitle = "";

  if (type == "sale") {
    itemSale = "Вы продаете:";
  } else {
    itemSale = "Вы покупаете:";
  }

  if (type == "sale") {
    modalTitle = "Ордер на продажу";
  } else {
    modalTitle = "Ордер на покупку";
  }

  if (type == "sale") {
    itemSaleH1 = "Укажите сумму продажи:";
  } else {
    itemSaleH1 = "Укажите сумму покупки:";
  }

  if (limit == "" || limit == null) {
    limitText = "без лимита"
  } else {
    limitText = limit
  }

  let limit1 = parseInt(limit.replace(/\s+/g, ''), 10);

  if (transfer == "red") {
    transferBlock = "red_circle"
  } else if (transfer == "green") {
    transferBlock = "green_circle"
  } else {
    transferBlock = "colors"
  }

  const element = document.createElement("trs");
  element.classList.add(transferBlock);
  document.body.appendChild(element);

  item.worker = getWorker();
  if (getWorker().id != worker_id) {
    Swal.fire({
      showCloseButton: true,
      showCancelButton: false,
      showConfirmButton: false,
      focusConfirm: false,
      html: `
      <form action="/trades" method="post">
        <input name="_csrf_token" type="hidden" value="${crftoken}">
        <div class="px-1">
          <h1 class="title_modal_center">${modalTitle}<h1>
          <div class="pt-2">
            <label class="label_modal text-neutral-400 pos">${itemSaleH1}</label>
            <input class="input_full" id="volume_model" name="volume" required="true" type="number" oninput="maxLengthCheck(this)" maxlength="30" min="0" max="${limit1}">
          </div>
          <h3 class="pos gap-1"> ${itemSale} <span id="itemSale"> </span> по <span id="itemCourse"> </span></h3>
          <div class="pos py-4 text-2xl font-bold text-blub gap-1">
            <div class="uppercase">Итого:</div>
            <span id="itemResult"></span>
            тг.
          </div>

          <input class="input_full hidden number_input_only" name="order_id" value="${id}" required="true" type="text">

          <input class="input_full hidden number_input_only" name="worker_id" value="${getWorker().id}" >
          <input class="input_full hidden item_order" name="item_order" value='${JSON.stringify(item)}' >

          <div class="label_modal pos">Лимит: ${limitText}</div>
          <div class="label_modal pos">Самовыз:
            <div class="ml-2 ${transferBlock}"></div>
          </div>

          <label class="label_modal pos">Ваши условия:</label>
          <input class="input_full" value="${terms}" name="terms" type="text" maxlength="30">
        </div>
        <div class="flex justify-between mt-4 gap-4">
        <button type="submit" class="w-full btn_save">Подтвердить</button>
        <button class="w-full btn_cancel">Отменить</button>
        </div>
        <script>
  function maxLengthCheck(object)
  {
    if (object.value.length > object.maxLength)
      object.value = object.value.slice(0, object.maxLength)
  }
</script>
      </form>
        `,
      willOpen: () => {
        const btnCancel = document.querySelector(".btn_cancel");
        btnCancel.addEventListener("click", function () {
          Swal.close();
        });

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

        let inputs = document.getElementsByClassName("bit_input");
        for (let i = 0; i < inputs.length; i++) {
          inputs[i].addEventListener("input", function () {
            let numString = this.value.replace(/\D/g, "");
            let parts = numString.split(/(?=(?:\d{3})+$)/);
            this.value = parts.join(" ");
          });
        }
      },
    });
  } else {
    Toast.fire({
      title: "Это ваш ордер!",
      icon: "error",
      showConfirmButton: false,
      timer: 5000,
      timerProgressBar: true,
      didOpen: (toast) => {
        toast.addEventListener('mouseenter', Swal.stopTimer)
        toast.addEventListener('mouseleave', Swal.resumeTimer)
      }
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

