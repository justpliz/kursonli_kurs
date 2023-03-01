import { order_click } from "../order_click"

export const templateNewOrder = (item) => {
  const templateTransfer = () => {
  if (item.transfer == "green") {
    return `<div name="order_tranfer" id="item.transfer" class="green_circle"></div>`
  } else if (item.transfer == "red") {
    return `<div name="order_tranfer" id="item.transfer" class="red_circle"></div>`
  }
    return `<div name="order_tranfer" id="item.transfer" class="transition-all colors"></div>`
  }

  const inner = `
  <td class="px-6 2xl:px-2 py-2">
     ${item.filial_name} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
    ${item.date}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
     ${item.currency_short_name} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
     ${item.course_sale}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
     ${item.volume}
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
    ${item.terms} 
  </td>
  <td class="px-6 2xl:px-2 py-2 border-x-2 border-gray-200">
    ${templateTransfer()}     
  </td>`

  const template = `
  <tr class="order-click text-black" data-item='${JSON.stringify(item)}' identifier='${item.id}' style="background-color: ${item.color}">
  ${inner}
  </tr>
    `
    return {template: template, inner: inner, type: item.type};
}