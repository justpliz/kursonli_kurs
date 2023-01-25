const Toast = Swal.mixin({
    toast: true,
    position: 'top-right',
    showConfirmButton: true,
  
  })
$(".order-click").click(function (){ 

    $(".order-click").removeClass("selected")
    $(this).addClass("selected")
 
    const item = JSON.parse(this.dataset.item)

    console.log(item)
    $("#org_title").text()
   document.querySelector( "#accept").dataset.item = this.dataset.item
})


$("#accept").click(function () {
    if (this.dataset.item == ""){
        Toast.fire({
            title: "Вы не выбрали ордер",
            icon: "error"
        })
        return ""
    }
    const item = JSON.parse(this.dataset.item)
    console.log(item)
    const { course_purchase, course_sale, currency_short_name, date, filial_id, id, organization, terms, volume, transfer, type } = item
    let itemSale = ""
    let itemSaleH1 = ""
    if (type == "sale") 
      itemSale = "Вы продаете:"
    else 
      itemSale = "Вы покупаете:"
        
    if (type == "sale") 
      itemSaleH1 = "Укажите сумму продажи:"
    else 
      itemSaleH1 = "Укажите сумму покупки:"
    
    Swal.fire({
        html: `
        <div> 
          <h1> Ордер на покупку<h1>
          <div>
            <label class="label_input">${itemSaleH1} </label>
            <input class="input_full number_input_only" id="volume_model" name="volume" required="true" type="text">
          </div>
          <h3> ${itemSale} <span id="itemSale"> </span> по <span id="itemCourse"> </span>  </h3>
        <div> 
          Итого:
          <span id="itemResult"></span>
        </div>
      </div>
        `,
        willOpen: () => {
          input()

          const volume_model = document.querySelector("#volume_model")
          const itemeSale = document.querySelector("#itemSale")
          const itemCourse = document.querySelector("#itemCourse")
          itemCourse.innerHTML = course_sale
          const itemResult = document.querySelector("#itemResult")
          volume_model.addEventListener("input", (e) => {
            const volume =  parseInt(e.currentTarget.value)
            const course_sale_float = parseFloat(course_sale)
            itemeSale.innerHTML = e.currentTarget.value
            itemResult.innerHTML = volume * course_sale_float
          })
        },
    showConfirmButton: false,
      })
  })
  

  function input () {
    var input = [...document.querySelectorAll('.number_input_only')];
    input.forEach((el) => {
      el.addEventListener("input", (e) => {
        e.currentTarget.value = e.currentTarget.value.replace(/[^0-9.]/g, '');
      })
   })
  }
  /*GOVNO ---------*/

  // `
  //   <form action="/worker/update_order" method="post">
  //   <div class="container_select">
  //   <input class="hidden" id="filial_id" name="filial_id" value="${filial_id}">
    
  //   <input class="hidden" id="course_id" name="course_id" value="${id}">
    
  //   <input required name="type" id="purchase" value="purchase" checked id="default-radio-2" type="radio"
  //     class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500">
  //   <label class="ml-2 text-sm font-medium text-gray-900" for="purchase">
  //     purchase
  //   </label>
  //   <input required name="type" id="sale" value="sale" checked id="default-radio-2" type="radio"
  //     class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500">
  //   <label class="ml-2 text-sm font-medium text-gray-900" for="sale">
  //     sale
  //   </label>
  //   </div>
    
  //   <input name="_csrf_token" type="hidden" value="CWM1QxI4PScIVX4lCn4xNScmFxcFXlkiH-q3TB_dRlIs85BSvKSyS6of">
  //   <div>
  //   <label class="label_input">Объем</label>
  //   <input class="input_full" id="volume" name="volume" value="${volume}" required="true" type="text">
  //   </div>
    
  //   <div>
  //   <label class="label_input">Цена продажи</label>
  //   <input class="input_full" id="course" value="${course_sale}" name="course" required="true" type="text">
  //   </div>
    
  //   <div>
  //   <label class="label_input">Цена покупки</label>
  //   <input class="input_full" id="limit" name="limit" value="${course_purchase}" required="true" type="text">
  //   </div>
    
  //   <div>
  //   <label class="label_input">Валюта</label>
  //   <select class="input_full" id="currency" name="currency" required="true">
  //     <option value="USD">USD</option>
  //   </select>
  //   </div>
  //   <div>
  //   <label class="label_input">Передача</label>
  //   <input name="transfer" type="hidden" value="false"><input id="green" name="transfer" type="checkbox" value="true">
  //   green
  //   <input name="transfer" type="hidden" value="false"><input id="red" name="transfer" type="checkbox" value="true">
  //   red
  //   <input name="transfer" type="hidden" value="false"><input id="red_green" name="transfer" type="checkbox"
  //     value="true">
  //   red_green
  //   </div>
  //   <div>
  //   <button class="btn_save mt-2" type="submit">Сохранить</button>
  //   </div>
  //   </form>`

