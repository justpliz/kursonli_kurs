import { order_click } from "../order_click"

export const templateNewOrder = (item) => {
    const templateTransfer = () => {

        if (item.transfer == "green") {
            return `  <div name="order_tranfer" id=" item.transfer " class="green_circle"></div>`
        }
         else if (item.transfer == "red") {
            return `  <div name="order_tranfer" id=" item.transfer " class="red_circle"></div>` 
        }
       
        return ` <div name="order_tranfer" id=" item.transfer " class="transition-all colors"></div>`
    }
    const template = `
    <tr class="bg-white order-click" data-id="${item.id}" data-item='${JSON.stringify(item)}'>
    <td class="px-6 py-2">
       ${item.filial_name} 
    </td>
    <td class="px-6 py-2 border-x-2 border-gray-200">
      ${ item.date }
    </td>
    <td class="px-6 py-2 border-x-2 border-gray-200">
       ${item.currency_short_name} 
    </td>
    <td class="px-6 py-2 border-x-2 border-gray-200">
       ${item.course_sale }
    </td>
    <td class="px-6 py-2 border-x-2 border-gray-200">
       ${item.volume }
    </td>
    <td class="px-6 py-2 border-x-2 border-gray-200">
      ${item.terms} 
    </td>
    <td class="px-6 py-2 border-x-2 border-gray-200">
         ${templateTransfer()}     
    </td>
  </tr>
    `
    document.querySelector(`#${item.type}_table`).insertAdjacentHTML("beforeend", template);
    setTimeout(()=> {
        document.querySelector(`[data-id='${item.id}']`).addEventListener("click", order_click)
    },100)
}